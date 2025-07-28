from flask import Blueprint, request, jsonify
from utils.db import get_connection
from utils.auth import get_user_id_from_token
import mysql.connector
from utils.logger import get_logger

logger = get_logger(__name__)
notifications = Blueprint('notifications', __name__)


@notifications.route('/notifications', methods=['GET'])
def get_notifications():
    current_user_id = get_user_id_from_token()
    if not current_user_id:
        return jsonify({'error': 'Unauthorized'}), 401
    
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT ID, Type, GroupID, Message, IsRead, CreatedAt 
        FROM Notifications 
        WHERE UserID = %s 
        ORDER BY CreatedAt DESC
    """, (current_user_id,))
    notifications = cursor.fetchall()
    return jsonify(notifications)


@notifications.route('/notifications/<int:notification_id>/read', methods=['POST'])
def mark_notification_as_read(notification_id):
    current_user_id = get_user_id_from_token()
    if not current_user_id:
        return jsonify({'error': 'Unauthorized'}), 401
    
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE Notifications 
        SET IsRead = TRUE 
        WHERE ID = %s AND UserID = %s
    """, (notification_id, current_user_id))
    conn.commit()
    return jsonify({'message': 'Notification marked as read'})
