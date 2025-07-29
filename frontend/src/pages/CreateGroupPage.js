import React, { useEffect, useState, useRef } from 'react';
import { useNavigate } from 'react-router-dom';

function CreateGroupPage() {
  const [groupName, setGroupName] = useState('');
  const [friends, setFriends] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedFriends, setSelectedFriends] = useState([]);
  const [loading, setLoading] = useState(false);
  const [showDropdown, setShowDropdown] = useState(false);
  const navigate = useNavigate();
  const dropdownRef = useRef(null);

  // Fetch user's friends
  useEffect(() => {
    const fetchFriends = async () => {
      const token = localStorage.getItem('token');
      const res = await fetch('http://localhost:5001/api/friends', {
        headers: { Authorization: `Bearer ${token}` }
      });
      const data = await res.json();
      if (res.ok) {
        setFriends(data.friends || []);
      } else {
        alert(data.error || 'Could not fetch friends');
      }
    };

    fetchFriends();
  }, []);

  // Close dropdown if clicking outside
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setShowDropdown(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleSelectFriend = (friend) => {
    if (!selectedFriends.find(f => f.ID === friend.ID)) {
      setSelectedFriends([...selectedFriends, friend]);
    }
    setSearchTerm('');
    setShowDropdown(false);
  };

  const handleRemoveFriend = (friendId) => {
    setSelectedFriends(selectedFriends.filter(f => f.ID !== friendId));
  };

  const handleCreateGroup = async () => {
    if (!groupName.trim()) {
      alert('Group name cannot be empty.');
      return;
    }

    try {
      setLoading(true);
      const token = localStorage.getItem('token');

      // Step 1: Create the group
      const groupRes = await fetch('http://localhost:5001/api/groups', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`
        },
        body: JSON.stringify({ name: groupName })
      });

      const groupData = await groupRes.json();

      if (!groupRes.ok) {
        throw new Error(groupData.error || 'Failed to create group');
      }

      const groupId = groupData.group_id;

      // Step 2: Add members to the group in one request
      if (selectedFriends.length > 0) {
      const userIds = selectedFriends.map(friend => friend.ID);

      await fetch(`http://localhost:5001/api/groups/${groupId}/members`, {
          method: 'POST',
          headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`
          },
          body: JSON.stringify({ user_ids: userIds })
      });
      }

      navigate('/groups');
    } catch (err) {
      alert(err.message || 'Something went wrong.');
    } finally {
      setLoading(false);
    }
  };

  // Filter friends only if searchTerm is non-empty
  const filteredFriends = searchTerm
    ? friends.filter(f =>
        f.Name.toLowerCase().includes(searchTerm.toLowerCase()) &&
        !selectedFriends.find(sel => sel.ID === f.ID)
      )
    : friends.filter(f => !selectedFriends.find(sel => sel.ID === f.ID)); // All unselected friends

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center">
      <div className="bg-white shadow-xl rounded-xl p-8 w-full max-w-xl">
        <h2 className="text-2xl font-bold mb-6 text-center text-indigo-700">Create a New Group</h2>

        <input
          className="w-full mb-4 p-3 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-indigo-400"
          placeholder="Group Name"
          value={groupName}
          onChange={e => setGroupName(e.target.value)}
        />

        <div className="mb-4 relative" ref={dropdownRef}>
          <input
            className="w-full p-3 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-indigo-400"
            placeholder="Search and add friends"
            value={searchTerm}
            onChange={e => {
              setSearchTerm(e.target.value);
              setShowDropdown(true);
            }}
            onFocus={() => setShowDropdown(true)}
          />
          {showDropdown && filteredFriends.length > 0 && (
            <ul className="absolute left-0 right-0 bg-white border mt-1 rounded shadow max-h-40 overflow-y-auto z-10">
              {filteredFriends.map(friend => (
                <li
                  key={friend.ID}
                  onClick={() => handleSelectFriend(friend)}
                  className="px-4 py-2 hover:bg-indigo-50 cursor-pointer"
                >
                  {friend.FirstName} <span className="text-gray-500 text-sm"> - {friend.Email}</span>
                </li>
              ))}
            </ul>
          )}
        </div>

        {selectedFriends.length > 0 && (
          <div className="flex flex-wrap gap-2 mb-6">
            {selectedFriends.map(friend => (
              <div
                key={friend.ID}
                className="flex items-center bg-indigo-100 text-indigo-800 px-3 py-1 rounded-full text-sm"
              >
                {friend.FirstName}
                <button
                  onClick={() => handleRemoveFriend(friend.ID)}
                  className="ml-2 text-indigo-500 hover:text-indigo-700"
                >
                  &times;
                </button>
              </div>
            ))}
          </div>
        )}

        <button
          onClick={handleCreateGroup}
          disabled={loading}
          className="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-2 rounded transition duration-200 disabled:opacity-50"
        >
          {loading ? 'Creating...' : 'Create Group'}
        </button>

        <button
          onClick={() => navigate('/groups')}
          className="w-full mt-4 text-indigo-600 hover:underline text-sm"
        >
          ← Back to Groups
        </button>
      </div>
    </div>
  );
}

export default CreateGroupPage;
