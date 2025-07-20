from flask import Blueprint, request, jsonify
from utils.db import get_connection
from utils.auth import get_user_id_from_token
import mysql.connector
from utils.logger import get_logger

logger = get_logger(__name__)
expenses = Blueprint('expenses', __name__)


@expenses.route('/expenses', methods=['POST'])
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
