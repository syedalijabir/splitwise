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
        # Get all group IDs the user is a part of
        cursor.execute("""
            SELECT GroupID FROM GroupMembers WHERE UserID = %s
        """, (current_user_id,))
        group_ids = [row['GroupID'] for row in cursor.fetchall()]

        if not group_ids:
            return jsonify([]), 200

        format_strings = ','.join(['%s'] * len(group_ids))

        # getch all expenses
        cursor.execute(f"""
            SELECT
                e.ID AS EntryID,
                'expense' AS Type,
                e.Name,
                e.Description,
                e.Amount,
                e.CreatedAt,
                u.Name AS PaidBy,
                NULL AS FromUser,
                NULL AS ToUser,
                g.Name AS GroupName
            FROM Expenses e
            JOIN Users u ON e.PaidBy = u.ID
            JOIN ExpenseGroups g ON e.GroupID = g.ID
            WHERE e.GroupID IN ({format_strings})
        """, tuple(group_ids))
        expenses = cursor.fetchall()

        # get settlements involving the user
        cursor.execute(f"""
            SELECT
                s.ID AS EntryID,
                'settlement' AS Type,
                NULL AS Name,
                CONCAT('Settlement from ', u1.Name, ' to ', u2.Name) AS Description,
                s.Amount,
                s.CreatedAt,
                NULL AS PaidBy,
                u1.Name AS FromUser,
                u2.Name AS ToUser,
                g.Name AS GroupName
            FROM Settlements s
            JOIN Users u1 ON s.FromUserID = u1.ID
            JOIN Users u2 ON s.ToUserID = u2.ID
            JOIN ExpenseGroups g ON s.GroupID = g.ID
            WHERE s.GroupID IN ({format_strings})
              AND (s.FromUserID = %s OR s.ToUserID = %s)
        """, tuple(group_ids + [current_user_id, current_user_id]))
        settlements = cursor.fetchall()

        # merge and sort in chronological order
        combined = expenses + settlements
        combined.sort(key=lambda x: x['CreatedAt'], reverse=True)

        return jsonify(combined), 200

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
        # all group IDs the user belongs to
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

        format_strings = ','.join(['%s'] * len(group_ids))

        # all members in those groups
        cursor.execute(f"""
            SELECT gm.GroupID, gm.UserID, u.Name
            FROM GroupMembers gm
            JOIN Users u ON gm.UserID = u.ID
            WHERE gm.GroupID IN ({format_strings})
        """, group_ids)
        member_data = cursor.fetchall()

        group_members = {}
        user_names = {}
        for row in member_data:
            gid = row['GroupID']
            uid = row['UserID']
            uname = row['Name']
            user_names[uid] = uname
            group_members.setdefault(gid, []).append(uid)

        # all the expenses in those groups
        cursor.execute(f"""
            SELECT ID, GroupID, PaidBy, Amount
            FROM Expenses
            WHERE GroupID IN ({format_strings})
        """, group_ids)
        expenses = cursor.fetchall()

        # debts from expenses
        balances = {}
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

        # settlements in those groups involving current_user
        cursor.execute(f"""
            SELECT GroupID, FromUserID, ToUserID, Amount
            FROM Settlements
            WHERE GroupID IN ({format_strings})
              AND (FromUserID = %s OR ToUserID = %s)
        """, group_ids + [current_user_id, current_user_id])
        settlements = cursor.fetchall()

        # subtacting settlements from balances
        for settlement in settlements:
            from_user = settlement['FromUserID']
            to_user = settlement['ToUserID']
            amount = settlement['Amount']

            if balances.get(from_user, {}).get(to_user):
                balances[from_user][to_user] -= amount
                if balances[from_user][to_user] <= 0:
                    del balances[from_user][to_user]
            else:
                balances.setdefault(to_user, {}).setdefault(from_user, 0)
                balances[to_user][from_user] -= amount

        # net balances involving current user
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
