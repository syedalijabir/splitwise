import React, { useEffect, useState } from 'react';
import TopNav from '../components/TopNav';

export default function FriendsPage() {
  const [friends, setFriends] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showAddModal, setShowAddModal] = useState(false);
  const [newFriendEmail, setNewFriendEmail] = useState('');
  const [error, setError] = useState(null);

  // Fetch friends on mount
useEffect(() => {
  const fetchFriends = async () => {
    try {
      const token = localStorage.getItem('token');
      const res = await fetch('http://localhost:5001/api/friends', {
        headers: { Authorization: `Bearer ${token}` },
      });

      const data = await res.json();

      if (!res.ok) {
        alert(data.error || 'Failed to fetch friends');
        return;
      }

      setFriends(data.friends);
    } catch (err) {
      alert('Error fetching friends');
      console.error(err);
    } finally {
      setLoading(false);  // Optional if you're showing a loader
    }
  };

  fetchFriends();
}, []);

const handleAddFriend = async () => {
  const email = newFriendEmail.trim();

  if (!email) {
    setError('Please enter an email');
    return;
  }

//   setError(null); // Clear any previous error
  const token = localStorage.getItem('token');

  try {
    // First: Send POST to add friend
    const res = await fetch('http://localhost:5001/api/friends/add', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({ email }),
    });

    const data = await res.json();

    if (!res.ok) {
      throw new Error(data?.error || 'Failed to add friend');
    }

    // Second: Fetch updated friends list
    const friendsRes = await fetch('http://localhost:5001/api/friends', {
      headers: { Authorization: `Bearer ${token}` },
    });

    const friendsData = await friendsRes.json();

    if (!friendsRes.ok || !Array.isArray(friendsData.friends)) {
      throw new Error(friendsData?.error || 'Failed to refresh friend list');
    }

    setFriends(friendsData.friends);
    setShowAddModal(false);
    setNewFriendEmail('');
  } catch (err) {
    console.error('Add friend failed:', err.message);
    setError(err.message);
  }
};

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <TopNav />

      {/* Content padding for fixed navbar */}
      <div className="pt-20 px-6 max-w-4xl mx-auto">
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-3xl font-bold text-indigo-700">Friends</h1>
          <button
            onClick={() => setShowAddModal(true)}
            className="bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded font-semibold"
          >
            + Add Friend
          </button>
        </div>

        {loading ? (
          <p>Loading friends...</p>
        ) : error ? (
          <p className="text-red-600">{error}</p>
        ) : friends.length === 0 ? (
          <p>No friends found. Add some!</p>
        ) : (
          <ul className="space-y-4">
            {friends.map(friend => (
              <li
                key={friend.ID}
                className="bg-white p-4 rounded shadow flex justify-between items-center"
              >
                <div>
                  <p className="font-semibold text-indigo-800">{friend.Name}</p>
                  <p className="text-sm text-gray-600">{friend.Email}</p>
                </div>
              </li>
            ))}
          </ul>
        )}

        {/* Add Friend Modal */}
        {showAddModal && (
          <div className="fixed inset-0 bg-black bg-opacity-30 flex justify-center items-center z-50">
            <div className="bg-white rounded p-6 w-full max-w-md shadow-lg">
              <h2 className="text-xl font-semibold mb-4 text-indigo-700">Add Friend</h2>
              <input
                type="email"
                placeholder="Friend's email"
                className="w-full p-2 border rounded mb-4"
                value={newFriendEmail}
                onChange={e => setNewFriendEmail(e.target.value)}
              />
              {error && <p className="text-red-600 mb-4">{error}</p>}
              <div className="flex justify-end space-x-4">
                <button
                  onClick={() => {
                    setShowAddModal(false);
                    setNewFriendEmail('');
                    setError(null);
                  }}
                  className="px-4 py-2 rounded border"
                >
                  Cancel
                </button>
                <button
                  onClick={handleAddFriend}
                  className="bg-indigo-600 text-white px-4 py-2 rounded font-semibold"
                >
                  Add
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
