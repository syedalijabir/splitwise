import React from 'react';
import { useNavigate } from 'react-router-dom';

function DashboardPage() {
  const navigate = useNavigate();

  return (
    <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <div className="bg-white shadow-xl rounded-xl p-8 w-full max-w-md text-center">
        <h2 className="text-2xl font-bold mb-6 text-indigo-700">Welcome to Splitwise</h2>

        <button
          onClick={() => navigate('/summary')}
          className="w-full bg-green-500 hover:bg-green-600 text-white font-semibold py-2 rounded transition duration-200"
        >
          View Summary
        </button>

        <button
          onClick={() => navigate('/groups')}
          className="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-2 rounded transition duration-200 mb-4"
        >
          View Groups
        </button>


      </div>
    </div>
  );
}

export default DashboardPage;
