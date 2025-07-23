from flask import Blueprint, request, jsonify
from utils.db import get_connection
from utils.auth import get_user_id_from_token
import mysql.connector
from utils.logger import get_logger

logger = get_logger(__name__)
friends = Blueprint('friends', __name__)

@friends.route('/friends/add', methods=['POST'])
def add_friend():
    current_user_id = get_user_id_from_token()
    if not current_user_id:
        return jsonify({'error': 'Unauthorized'}), 401
    
    data = request.get_json()
    friend_email = data.get('email')

    if not friend_email:
        return jsonify({'error': 'Email is required'}), 400

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT ID FROM Users WHERE Email = %s", (friend_email,))
        friend = cursor.fetchone()

        if not friend:
            return jsonify({'error': 'User not found'}), 404

        friend_id = friend['ID']
        if friend_id == current_user_id:
            return jsonify({'error': 'Cannot add yourself'}), 400

        cursor.execute(
            "INSERT INTO Friends (UserID, FriendID) VALUES (%s, %s)",
            (current_user_id, friend_id)
        )
        conn.commit()
        return jsonify({'message': 'Friend added successfully'}), 201

    except mysql.connector.IntegrityError:
        return jsonify({'error': 'Already friends'}), 409
    finally:
        cursor.close()
        conn.close()


@friends.route('/friends', methods=['GET'])
def get_friends():
    current_user_id = get_user_id_from_token()
    if not current_user_id:
        return jsonify({'error': 'Unauthorized'}), 401

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT U.ID, U.Name, U.Email
            FROM Friends F
            JOIN Users U ON F.FriendID = U.ID
            WHERE F.UserID = %s
        """, (current_user_id,))
        friends = cursor.fetchall()
        return jsonify({'friends': friends})
    finally:
        cursor.close()
        conn.close()
