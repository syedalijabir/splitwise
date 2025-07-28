from flask import Blueprint, request, jsonify
from utils.db import get_connection
from utils.auth import get_user_id_from_token
import bcrypt
import jwt
import os
from utils.logger import get_logger

logger = get_logger(__name__)

auth = Blueprint('auth', __name__)
SECRET_KEY = os.getenv('JWT_SECRET')


@auth.route('/signup', methods=['POST'])
def signup():
    data = request.json
    first_name = data.get('first_name')
    last_name = data.get('last_name')
    email = data.get('email')
    password = data.get('password')

    if not all([first_name, last_name, email, password]):
        return jsonify({'error': 'Missing fields'}), 400

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT * FROM Users WHERE Email = %s", (email,))
    if cursor.fetchone():
        return jsonify({'error': 'Email already exists'}), 400

    hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
    cursor.execute("INSERT INTO Users (FirstName, LastName, Email, PasswordHash) VALUES (%s, %s, %s)", (first_name, last_name, email, hashed))
    conn.commit()

    cursor.close()
    conn.close()

    return jsonify({'message': 'User registered successfully'}), 201


@auth.route('/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('email')
    password = data.get('password')

    if not all([email, password]):
        return jsonify({'error': 'Missing fields'}), 400

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT * FROM Users WHERE Email = %s", (email,))
    user = cursor.fetchone()

    if not user or not bcrypt.checkpw(password.encode('utf-8'), user['PasswordHash'].encode('utf-8')):
        logger.error(f"Invalid credentials for user: {email}")
        return jsonify({'error': 'Invalid credentials'}), 401

    payload = {
        'user_id': user['ID'],
        'email': user['Email']
    }
    token = jwt.encode(payload, SECRET_KEY, algorithm='HS256')

    cursor.close()
    conn.close()

    return jsonify(
        {
            'token': token, 
            'user': {
                'id': user['ID'], 
                'name': user['FirstName'],
                'email': user['Email']
            }
        }
    )


@auth.route('/me', methods=['GET'])
def get_current_user():
    current_user_id = get_user_id_from_token()
    if not current_user_id:
        return jsonify({'error': 'Unauthorized'}), 401
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT ID, FirstName, Email FROM Users WHERE ID = %s", (current_user_id,))
    user = cursor.fetchone()
    return jsonify(user)
