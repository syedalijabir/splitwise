import React from 'react';
import { useNavigate } from 'react-router-dom';

function TopNav() {
  const navigate = useNavigate();

  const handleDashboard = () => navigate('/dashboard');
  const handleNotifications = () => navigate('/notifications');
  const handleSignOut = () => {
    localStorage.clear();
    navigate('/login');
  };

  return (
    <div className="bg-white shadow-md py-3 px-6 flex justify-between items-center fixed top-0 left-0 w-full z-50">
      <h1
        onClick={handleDashboard}
        className="text-xl font-bold text-indigo-700 cursor-pointer"
      >
        Splitwise
      </h1>
      <div className="space-x-4">
        <button
          onClick={handleDashboard}
          className="text-indigo-600 hover:text-indigo-800 font-medium"
        >
          Dashboard
        </button>
        <button
          onClick={handleNotifications}
          className="text-indigo-600 hover:text-indigo-800 font-medium"
        >
          Notifications
        </button>
        <button
          onClick={handleSignOut}
          className="text-red-500 hover:text-red-700 font-medium"
        >
          Sign Out
        </button>
      </div>
    </div>
  );
}

export default TopNav;
