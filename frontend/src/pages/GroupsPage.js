import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';

const colorThemes = [
  'from-indigo-100 to-indigo-200',
  'from-blue-100 to-blue-200',
  'from-green-100 to-green-200',
  'from-pink-100 to-pink-200',
  'from-yellow-100 to-yellow-200',
  'from-purple-100 to-purple-200',
];

function getInitials(name) {
  return name
    .split(' ')
    .map(word => word[0])
    .join('')
    .toUpperCase();
}

function GroupsPage() {
  const [groups, setGroups] = useState([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchGroupsWithMembers = async () => {
      try {
        const token = localStorage.getItem('token');
        const res = await fetch('http://localhost:5001/api/groups', {
          headers: { Authorization: `Bearer ${token}` },
        });
        const groupData = await res.json();

        if (!res.ok) {
          alert(groupData.error || 'Failed to fetch groups');
          return;
        }

        // Fetch members for each group in parallel
        const groupsWithMembers = await Promise.all(
          groupData.map(async group => {
            try {
              const memberRes = await fetch(
                `http://localhost:5001/api/groups/${group.ID}/members`,
                {
                  headers: { Authorization: `Bearer ${token}` },
                }
              );
              const members = await memberRes.json();
              return {
                ...group,
                memberCount: members.length,
              };
            } catch (err) {
              console.error(`Error fetching members for group ${group.ID}`, err);
              return {
                ...group,
                memberCount: 0,
              };
            }
          })
        );

        setGroups(groupsWithMembers);
      } catch (err) {
        alert('Error fetching groups');
      } finally {
        setLoading(false);
      }
    };

    fetchGroupsWithMembers();
  }, []);

  const handleCreateGroup = () => {
    navigate('/create-group');
  };

  if (loading) return <div className="text-center mt-10 text-gray-600">Loading groups...</div>;

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-6 flex flex-col items-center">
      <div className="w-full max-w-5xl flex justify-between items-center mb-8">
        <h2 className="text-3xl font-bold text-indigo-700">Your Groups</h2>
        <button
          onClick={handleCreateGroup}
          className="bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-md font-medium transition"
        >
          + Create Group
        </button>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6 w-full max-w-5xl">
        {groups.map((group, idx) => (
          <div
            key={group.ID}
            onClick={() => navigate(`/groups/${group.ID}`, { state: { groupName: group.Name } })}
            className={`cursor-pointer bg-gradient-to-br ${colorThemes[idx % colorThemes.length]} shadow-md hover:shadow-xl transition-shadow rounded-xl p-6 border border-gray-200 hover:border-indigo-500`}
          >
            <div className="flex items-center space-x-4 mb-4">
              <div className="bg-white shadow rounded-full h-12 w-12 flex items-center justify-center text-indigo-700 font-bold text-lg">
                {getInitials(group.CreatedBy)}
              </div>
              <div className="text-left">
                <h3 className="text-xl font-semibold text-indigo-800">{group.Name}</h3>
                <p className="text-sm text-gray-700">Created by: {group.CreatedBy}</p>
              </div>
            </div>

            <p className="text-gray-600 text-sm mb-2">
              Members: <span className="font-medium">{group.memberCount}</span>
            </p>
            <p className="text-xs text-gray-500">{new Date(group.CreatedAt).toLocaleString()}</p>
          </div>
        ))}
      </div>
    </div>
  );
}

export default GroupsPage;
