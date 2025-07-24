import React, { useEffect, useState } from 'react';

function SummaryPage() {
  const [summary, setSummary] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchSummary = async () => {
      try {
        const token = localStorage.getItem('token');
        const res = await fetch('http://localhost:5001/api/expenses/summary', {
          headers: { Authorization: `Bearer ${token}` }
        });
        const data = await res.json();
        if (res.ok) {
          setSummary(data);
        } else {
          alert(data.error || 'Failed to fetch summary');
        }
      } catch (err) {
        alert('Error fetching summary');
      } finally {
        setLoading(false);
      }
    };

    fetchSummary();
  }, []);

  if (loading) return <div className="text-center mt-10 text-gray-600">Loading summary...</div>;

  if (!summary) return null;

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center px-4">
      <div className="bg-white shadow-xl rounded-xl p-8 w-full max-w-2xl">
        <h2 className="text-2xl font-bold text-indigo-700 mb-4 text-center">Expense Summary</h2>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-6">
          <div className="bg-red-100 text-red-700 rounded-lg p-4 text-center font-semibold">
            💸 You owe: ${summary.total_owed_by_user.toFixed(2)}
          </div>
          <div className="bg-green-100 text-green-700 rounded-lg p-4 text-center font-semibold">
            💰 You're owed: ${summary.total_owed_to_user.toFixed(2)}
          </div>
        </div>

        <div className="space-y-3">
          {summary.details.map((item, idx) => (
            <div
              key={idx}
              className={`p-4 rounded-lg shadow-sm flex justify-between items-center ${
                item.to ? 'bg-red-50 text-red-700' : 'bg-green-50 text-green-700'
              }`}
            >
              {item.to ? (
                <span>You owe <strong>{item.to}</strong></span>
              ) : (
                <span><strong>{item.from}</strong> owes you</span>
              )}
              <span className="font-semibold">${item.amount.toFixed(2)}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

export default SummaryPage;
