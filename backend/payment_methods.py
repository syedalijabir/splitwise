from flask import Blueprint, request, jsonify
from utils.db import get_connection
from utils.auth import get_user_id_from_token
import mysql.connector
from utils.logger import get_logger

logger = get_logger(__name__)
payment_methods = Blueprint('payment_methods', __name__)


@payment_methods.route('/payment_methods', methods=['GET'])
def get_payment_methods():
    current_user_id = get_user_id_from_token()
    if not current_user_id:
        return jsonify({'error': 'Unauthorized'}), 401

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT ID, Type FROM PaymentMethods ORDER BY Type")
        rows = cursor.fetchall()
        return jsonify(rows), 200

    except Exception as e:
        logger.error(f"Error fetching payment methods: {str(e)}")
        return jsonify({'error': 'Failed to fetch payment methods'}), 500
    finally:
        cursor.close()
        conn.close()
