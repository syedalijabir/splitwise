from flask import Blueprint, request, jsonify
from utils.db import get_connection
from utils.auth import get_user_id_from_token
import mysql.connector
from utils.logger import get_logger

logger = get_logger(__name__)
groups = Blueprint('groups', __name__)


@groups.route('/groups', methods=['POST'])
def create_group():
    current_user_id = get_user_id_from_token()
    if not current_user_id:
        return jsonify({'error': 'Unauthorized'}), 401

    data = request.get_json()
    group_name = data.get('name')

    if not group_name:
        return jsonify({'error': 'Group name is required'}), 400

    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO ExpenseGroups (Name, CreatedBy) VALUES (%s, %s)",
            (group_name, current_user_id)
        )
        conn.commit()
        group_id = cursor.lastrowid
        cursor.close()
        conn.close()
        return jsonify({'message': 'Group created', 'group_id': group_id}), 201
    except Exception as e:
        print("DB error:", e)
        return jsonify({'error': 'Database error'}), 500


@groups.route('/groups/<int:group_id>/members', methods=['POST'])
def add_member(group_id):
    current_user_id = get_user_id_from_token()
    if not current_user_id:
        return jsonify({'error': 'Unauthorized'}), 401
    
    data = request.get_json()
    new_member_id = data.get('user_id')

    if not new_member_id:
        return jsonify({'error': 'Missing user_id'}), 400

    conn = get_connection()
    cursor = conn.cursor()

    try:
        # Check if group exists
        cursor.execute("SELECT ID FROM ExpenseGroups WHERE ID = %s", (group_id,))
        if cursor.fetchone() is None:
            return jsonify({'error': 'Group not found'}), 404

        # Check if requester is the creator, only admin can add members to groups
        cursor.execute("SELECT CreatedBy FROM ExpenseGroups WHERE ID = %s", (group_id,))
        created_by = cursor.fetchone()[0]
        if created_by != current_user_id:
            return jsonify({'error': 'Only group creator can add members'}), 403

        # Check if new member is a friend
        cursor.execute("""
            SELECT 1 FROM Friends
            WHERE (UserID = %s AND FriendID = %s)
            OR (UserID = %s AND FriendID = %s)
            LIMIT 1
        """, (current_user_id, new_member_id, new_member_id, current_user_id))
        
        if cursor.fetchone() is None:
            return jsonify({'error': 'Can only add friends to groups'}), 403

        cursor.execute(
            "INSERT INTO GroupMembers (GroupID, UserID) VALUES (%s, %s)",
            (group_id, new_member_id)
        )
        conn.commit()
        return jsonify({'message': 'User added to group'}), 201

    except mysql.connector.IntegrityError as e:
        return jsonify({'error': 'User already in group or invalid user ID'}), 409
    except Exception as e:
        logger.error(str(e))
        return jsonify({'error': 'Internal Server Error'}), 500
    finally:
        cursor.close()
        conn.close()



@groups.route("/groups", methods=["GET"])
def get_user_groups():
    current_user_id = get_user_id_from_token()
    if not current_user_id:
        return jsonify({'error': 'Unauthorized'}), 401

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        query = """
        (
            SELECT g.ID, g.Name, g.CreatedAt, u.Name AS CreatedBy
            FROM ExpenseGroups g
            JOIN GroupMembers gm ON g.ID = gm.GroupID
            JOIN Users u ON g.CreatedBy = u.ID
            WHERE gm.UserID = %s
        )
        UNION
        (
            SELECT g.ID, g.Name, g.CreatedAt, u.Name AS CreatedBy
            FROM ExpenseGroups g
            JOIN Users u ON g.CreatedBy = u.ID
            WHERE g.CreatedBy = %s
        )
        """
        cursor.execute(query, (current_user_id, current_user_id))
        groups = cursor.fetchall()

        return jsonify(groups)
    except Exception as e:
        logger.error(f"Error fetching group members: {str(e)}")
        return jsonify({'error': 'Internal Server Error'}), 500
    finally:
        cursor.close()
        conn.close()


@groups.route('/groups/<int:group_id>/members', methods=['GET'])
def get_group_members(group_id):
    current_user_id = get_user_id_from_token()
    if not current_user_id:
        return jsonify({'error': 'Unauthorized'}), 401

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        # Check if the group exists
        cursor.execute("SELECT ID FROM ExpenseGroups WHERE ID = %s", (group_id,))
        if cursor.fetchone() is None:
            return jsonify({'error': 'Group not found'}), 404

        # Check if current user is a member of the group
        cursor.execute("""
            SELECT 1 FROM GroupMembers
            WHERE GroupID = %s AND UserID = %s
        """, (group_id, current_user_id))
        
        if cursor.fetchone() is None:
            return jsonify({'error': 'Forbidden: You are not a member of this group'}), 403

        cursor.execute("""
            SELECT u.ID, u.Name, u.Email, gm.AddedAt
            FROM GroupMembers gm
            JOIN Users u ON gm.UserID = u.ID
            WHERE gm.GroupID = %s
        """, (group_id,))
        
        members = cursor.fetchall()
        return jsonify(members), 200

    except Exception as e:
        logger.error(f"Error fetching group members: {str(e)}")
        return jsonify({'error': 'Internal Server Error'}), 500
    finally:
        cursor.close()
        conn.close()


@groups.route('/groups/<int:group_id>/expenses', methods=['POST'])
def add_expense(group_id):
    current_user_id = get_user_id_from_token()
    if not current_user_id:
        return jsonify({'error': 'Unauthorized'}), 401

    data = request.get_json()
    name = data.get('name')
    description = data.get('description', None)
    amount = data.get('amount')
    paid_by = data.get('paid_by')

    if not name or not amount or not paid_by:
        return jsonify({'error': 'Name, amount and paid_by are required fields'}), 400

    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("SELECT ID FROM ExpenseGroups WHERE ID = %s", (group_id,))
        if cursor.fetchone() is None:
            return jsonify({'error': 'Group not found'}), 404

        # Check if current user is a member of the group
        cursor.execute("""
            SELECT 1 FROM GroupMembers
            WHERE GroupID = %s AND UserID = %s
        """, (group_id, current_user_id))
        if cursor.fetchone() is None:
            return jsonify({'error': 'Unauthorized: You are not a member of this group'}), 403

        cursor.execute("""
            SELECT 1 FROM GroupMembers
            WHERE GroupID = %s AND UserID = %s
        """, (group_id, paid_by))
        if cursor.fetchone() is None:
            return jsonify({'error': 'Paid_by user is not a member of the group'}), 400

        cursor.execute("""
            INSERT INTO Expenses (GroupID, PaidBy, Name, Description, Amount)
            VALUES (%s, %s, %s, %s, %s)
        """, (group_id, paid_by, name, description, amount))
        conn.commit()

        return jsonify({'message': 'Expense added successfully'}), 201

    except Exception as e:
        logger.error(f"Error adding expense: {str(e)}")
        return jsonify({'error': 'Internal Server Error'}), 500

    finally:
        cursor.close()
        conn.close()


@groups.route('/groups/<int:group_id>/expenses', methods=['GET'])
def get_group_expenses(group_id):
    current_user_id = get_user_id_from_token()
    if not current_user_id:
        return jsonify({'error': 'Unauthorized'}), 401

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        # Verify user is in the group
        cursor.execute("""
            SELECT 1 FROM GroupMembers
            WHERE GroupID = %s AND UserID = %s
        """, (group_id, current_user_id))
        if cursor.fetchone() is None:
            return jsonify({'error': 'Forbidden: You are not a member of this group'}), 403

        cursor.execute("""
            SELECT e.ID, e.Name, e.Description, e.Amount, e.CreatedAt,
                   u.Name AS PaidBy
            FROM Expenses e
            JOIN Users u ON e.PaidBy = u.ID
            WHERE e.GroupID = %s
            ORDER BY e.CreatedAt DESC
        """, (group_id,))
        
        expenses = cursor.fetchall()
        return jsonify(expenses), 200

    except Exception as e:
        logger.error(f"Error fetching expenses for group {group_id}: {str(e)}")
        return jsonify({'error': 'Internal Server Error'}), 500
    finally:
        cursor.close()
        conn.close()

@groups.route('/groups/<int:group_id>/balances', methods=['GET'])
def get_group_balances(group_id):
    current_user_id = get_user_id_from_token()
    if not current_user_id:
        return jsonify({'error': 'Unauthorized'}), 401

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT 1 FROM ExpenseGroups WHERE ID = %s", (group_id,))
        if cursor.fetchone() is None:
            return jsonify({'error': 'Group not found'}), 404

        cursor.execute("SELECT 1 FROM GroupMembers WHERE GroupID = %s AND UserID = %s", (group_id, current_user_id))
        if cursor.fetchone() is None:
            return jsonify({'error': 'You are not a member of this group'}), 403

        # Get all group members
        cursor.execute("""
            SELECT u.ID, u.Name FROM GroupMembers gm
            JOIN Users u ON gm.UserID = u.ID
            WHERE gm.GroupID = %s
        """, (group_id,))
        members = cursor.fetchall()
        member_ids = [m['ID'] for m in members]
        id_to_name = {m['ID']: m['Name'] for m in members}

        balances = {
            payer: {
                receiver: 0 for receiver in member_ids if receiver != payer
                } for payer in member_ids
            }

        # Get all expenses
        cursor.execute("""
            SELECT PaidBy, Amount FROM Expenses WHERE GroupID = %s
        """, (group_id,))
        expenses = cursor.fetchall()

        for expense in expenses:
            paid_by = expense['PaidBy']
            amount = expense['Amount']
            share = round(amount / len(member_ids), 2)

            for member_id in member_ids:
                if member_id == paid_by:
                    continue
                balances[member_id][paid_by] += share

        # settle debts
        settlements = []
        for debtor in member_ids:
            for creditor in member_ids:
                if debtor == creditor:
                    continue
                net = round(balances[debtor][creditor] - balances[creditor][debtor], 2)
                if net > 0:
                    settlements.append({
                        "from": id_to_name[debtor],
                        "to": id_to_name[creditor],
                        "amount": net
                    })

        return jsonify(settlements), 200

    except Exception as e:
        logger.error(f"Error calculating balances: {str(e)}")
        return jsonify({'error': 'Internal Server Error'}), 500
    finally:
        cursor.close()
        conn.close()


@groups.route('/groups/<int:group_id>/settle', methods=['POST'])
def settle_between_users(group_id):
    current_user_id = get_user_id_from_token()
    if not current_user_id:
        return jsonify({'error': 'Unauthorized'}), 401

    data = request.get_json()
    from_user = data.get('from_user_id')
    to_user = data.get('to_user_id')
    amount = data.get('amount')

    if not from_user or not to_user or not amount:
        return jsonify({'error': 'Missing fields'}), 400

    conn = get_connection()
    cursor = conn.cursor()

    try:
        # Validate both users are in group
        cursor.execute("""
            SELECT COUNT(*) FROM GroupMembers
            WHERE GroupID = %s AND UserID IN (%s, %s)
        """, (group_id, from_user, to_user))
        count = cursor.fetchone()[0]
        if count < 2:
            return jsonify({'error': 'Both users must be in the group'}), 400

        cursor.execute("""
            INSERT INTO Settlements (GroupID, FromUserID, ToUserID, Amount)
            VALUES (%s, %s, %s, %s)
        """, (group_id, from_user, to_user, amount))

        conn.commit()
        return jsonify({'message': 'Settlement recorded'}), 201

    except Exception as e:
        conn.rollback()
        logger.error(f"Error settling: {str(e)}")
        return jsonify({'error': 'Internal Server Error'}), 500
    finally:
        cursor.close()
        conn.close()
