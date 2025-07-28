import React from 'react';
import { useNavigate } from 'react-router-dom';
import TopNav from '../components/TopNav';

function DashboardPage() {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <TopNav />
      {/* Page Content */}
      <div className="flex items-center justify-center min-h-[80vh]">
        <div className="bg-white shadow-xl rounded-xl p-8 w-full max-w-md text-center">
          <h2 className="text-2xl font-bold mb-8 text-indigo-700">Welcome to Splitwise</h2>

          <div className="flex flex-col gap-4">
            <button
              onClick={() => navigate('/summary')}
              className="w-full bg-green-500 hover:bg-green-600 text-white font-semibold py-2 rounded transition duration-200"
            >
              Summary
            </button>

            <button
              onClick={() => navigate('/groups')}
              className="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-2 rounded transition duration-200"
            >
              Groups
            </button>

            <button
              onClick={() => navigate('/friends')}
              className="w-full bg-slate-600 hover:bg-slate-700 text-white font-semibold py-2 rounded transition duration-200"
            >
              Friends
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

export default DashboardPage;
