from flask import Blueprint, request, jsonify
from utils.db import get_connection
from utils.auth import get_user_id_from_token
import mysql.connector
from utils.logger import get_logger

logger = get_logger(__name__)
categories = Blueprint('categories', __name__)


@categories.route('/categories', methods=['GET'])
def get_categories():
    current_user_id = get_user_id_from_token()
    if not current_user_id:
        return jsonify({'error': 'Unauthorized'}), 401

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT ID, Name FROM Categories ORDER BY Name")
        rows = cursor.fetchall()
        return jsonify(rows), 200

    except Exception as e:
        logger.error(f"Error fetching categories: {str(e)}")
        return jsonify({'error': 'Failed to fetch categories'}), 500
    finally:
        cursor.close()
        conn.close()
