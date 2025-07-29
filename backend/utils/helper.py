from utils.db import get_connection
import mysql.connector
from utils.logger import get_logger
logger = get_logger(__name__)


def log_activity(group_id, user_id, action_type, description):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO ActivityFeed (GroupID, UserID, ActionType, Description) 
        VALUES (%s, %s, %s, %s)
    """, (group_id, user_id, action_type, description))
    conn.commit()


def send_notification(user_id, type, group_id, message):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO Notifications (UserID, Type, GroupID, Message) 
        VALUES (%s, %s, %s, %s)
    """, (user_id, type, group_id, message))
    conn.commit()
