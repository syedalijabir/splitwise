from flask import Blueprint, request, jsonify
from utils.db import get_connection
from utils.auth import get_user_id_from_token
import mysql.connector
from utils.logger import get_logger

logger = get_logger(__name__)
expenses = Blueprint('expenses', __name__)


@expenses.route('/expenses', methods=['GET'])
def get_user_expenses_across_groups():
    current_user_id = get_user_id_from_token()
    if not current_user_id:
        return jsonify({'error': 'Unauthorized'}), 401
    
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        # Fetch expenses from all groups where user is a member
        cursor.execute("""
            SELECT e.ID, e.Name, e.Description, e.Amount, e.CreatedAt,
                   u.Name AS PaidBy, g.Name AS GroupName
            FROM Expenses e
            JOIN Users u ON e.PaidBy = u.ID
            JOIN ExpenseGroups g ON e.GroupID = g.ID
            WHERE e.GroupID IN (
                SELECT GroupID FROM GroupMembers WHERE UserID = %s
            )
            ORDER BY e.CreatedAt DESC
        """, (current_user_id,))
        
        expenses = cursor.fetchall()
        return jsonify(expenses), 200

    except Exception as e:
        logger.error(f"Error fetching user's expenses across groups: {str(e)}")
        return jsonify({'error': 'Internal Server Error'}), 500
    finally:
        cursor.close()
        conn.close()


@expenses.route('/expenses/summary', methods=['GET'])
def get_user_global_balance():
    current_user_id = get_user_id_from_token()
    if not current_user_id:
        return jsonify({'error': 'Unauthorized'}), 401

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        # Get all groups user is in
        cursor.execute("""
            SELECT GroupID FROM GroupMembers WHERE UserID = %s
        """, (current_user_id,))
        group_ids = [row['GroupID'] for row in cursor.fetchall()]
        if not group_ids:
            return jsonify({
                "total_owed_by_user": 0.0,
                "total_owed_to_user": 0.0,
                "details": []
            }), 200

        # Get all members of each group
        cursor.execute("""
            SELECT gm.GroupID, gm.UserID, u.Name
            FROM GroupMembers gm
            JOIN Users u ON gm.UserID = u.ID
            WHERE gm.GroupID IN (%s)
        """ % ','.join(['%s'] * len(group_ids)), group_ids)
        member_data = cursor.fetchall()

        # Map group_id -> list of member IDs
        group_members = {}
        user_names = {}
        for row in member_data:
            gid = row['GroupID']
            uid = row['UserID']
            uname = row['Name']
            user_names[uid] = uname
            group_members.setdefault(gid, []).append(uid)

        # Get all expenses
        cursor.execute("""
            SELECT ID, GroupID, PaidBy, Amount FROM Expenses
            WHERE GroupID IN (%s)
        """ % ','.join(['%s'] * len(group_ids)), group_ids)
        expenses = cursor.fetchall()

        # Calculate per-expense debts
        balances = {}  # balances[from_user][to_user] = amount
        for expense in expenses:
            gid = expense['GroupID']
            payer = expense['PaidBy']
            amt = expense['Amount']
            members = group_members[gid]
            share = round(amt / len(members), 2)

            for member in members:
                if member == payer:
                    continue
                balances.setdefault(member, {}).setdefault(payer, 0)
                balances[member][payer] += share

        total_owed_by_user = 0.0
        total_owed_to_user = 0.0
        details = []

        visited_users = set()

        for other_user_id in user_names:
            if other_user_id == current_user_id or other_user_id in visited_users:
                continue

            owed_to_them = balances.get(current_user_id, {}).get(other_user_id, 0.0)
            they_owe = balances.get(other_user_id, {}).get(current_user_id, 0.0)

            net_balance = round(float(they_owe) - float(owed_to_them), 2)

            if net_balance > 0:
                details.append({
                    "from": user_names[other_user_id],
                    "amount": net_balance
                })
                total_owed_to_user += float(net_balance)
            elif net_balance < 0:
                details.append({
                    "to": user_names[other_user_id],
                    "amount": abs(net_balance)
                })
                total_owed_by_user += abs(float(net_balance))

            visited_users.add(other_user_id)

        return jsonify({
            "total_owed_by_user": round(total_owed_by_user, 2),
            "total_owed_to_user": round(total_owed_to_user, 2),
            "details": details
        }), 200

    except Exception as e:
        logger.error(f"Error fetching user global balance: {str(e)}")
        return jsonify({'error': 'Internal Server Error'}), 500

    finally:
        cursor.close()
        conn.close()
