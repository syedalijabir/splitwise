import TopNav from '../components/TopNav';
import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';

function NotificationsPage() {
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  // Map type to headline
  const getNotificationTitle = (type) => {
    switch (type) {
      case 'invite':
        return "You’ve got a group invite";
      case 'expense_update':
        return "New expense added";
      case 'settlement':
        return "A new settlement was posted";
      default:
        return "Notification";
    }
  };

  useEffect(() => {
    const fetchNotifications = async () => {
      try {
        const token = localStorage.getItem('token');
        const res = await fetch('http://localhost:5001/api/notifications', {
          headers: {
            Authorization: `Bearer ${token}`
          }
        });
        const data = await res.json();
        if (!res.ok) throw new Error(data.error || 'Failed to fetch notifications');

        setNotifications(
          data.sort((a, b) => new Date(b.CreatedAt) - new Date(a.CreatedAt))
        );
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchNotifications();
  }, []);

  const handleNotificationClick = async (notificationId, groupId) => {
    if (!notificationId) {
        console.error("Missing notification ID");
        return;
    }
    try {
      const token = localStorage.getItem('token');
      await fetch(`http://localhost:5001/api/notifications/${notificationId}/read`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}` }
      });
      navigate(`/groups/${groupId}`);
    } catch (err) {
      console.error('Failed to mark notification as read', err);
      navigate(`/groups/${groupId}`); // still go to group page
    }
  };

  return (
    <div className="mt-20 max-w-2xl mx-auto px-4">
      <TopNav />
      <h2 className="text-2xl font-bold mb-6 text-indigo-700">Notifications</h2>

      {loading ? (
        <p className="text-gray-600">Loading notifications...</p>
      ) : notifications.length === 0 ? (
        <p className="text-gray-500">No notifications yet.</p>
      ) : (
        <ul className="space-y-4">
          {notifications.map((n) => (
            <li
            key={n.id}
            onClick={() => handleNotificationClick(n.ID, n.GroupID)}
            className={`relative cursor-pointer px-4 py-3 rounded-lg border shadow-sm transition hover:bg-indigo-50 ${
                n.IsRead ? 'bg-white' : 'bg-indigo-100 border-indigo-300'
            }`}
            >
            {/* Red bubble for unread */}
            {!n.IsRead && (
                <span className="absolute top-2 right-2 h-3 w-3 bg-red-500 rounded-full border-2 border-white"></span>
            )}

            <p className="text-sm font-semibold text-indigo-800">
                {getNotificationTitle(n.Type)}
            </p>
            <p className="text-sm text-gray-800 mt-1">{n.Message}</p>
            <p className="text-xs text-gray-500 mt-1">
                {new Date(n.CreatedAt).toLocaleString()}
            </p>
            </li>

          ))}
        </ul>
      )}
    </div>
  );
}

export default NotificationsPage;
