import React, { useEffect, useState } from 'react';
import { useParams, useLocation } from 'react-router-dom';

function GroupDetailsPage() {
  const { groupId } = useParams();
  const location = useLocation();
  const [groupName, setGroupName] = useState(location.state?.groupName || '');
  const [balances, setBalances] = useState([]);
  const [expenses, setExpenses] = useState([]);
  const [settlements, setSettlements] = useState([]);
  const [currentUserName, setCurrentUserName] = useState('');
  const [currentUserId, setCurrentUserId] = useState(null);

  // Modal controls
  const [showExpenseForm, setShowExpenseForm] = useState(false);
  const [showSettlementForm, setShowSettlementForm] = useState(false);

  // Form inputs for expense
  const [expenseName, setExpenseName] = useState('');
  const [expenseDescription, setExpenseDescription] = useState('');
  const [expenseAmount, setExpenseAmount] = useState('');
  const [expensePaidBy, setExpensePaidBy] = useState(null);

  // Form inputs for settlement
  const [settleFromUser, setSettleFromUser] = useState(null);
  const [settleToUser, setSettleToUser] = useState(null);
  const [settleAmount, setSettleAmount] = useState('');
  const [groupMembers, setGroupMembers] = useState([]);

  useEffect(() => {
    const token = localStorage.getItem('token');

    const fetchUser = async () => {
      const res = await fetch('http://localhost:5001/api/me', {
        headers: { Authorization: `Bearer ${token}` }
      });
      const data = await res.json();
      setCurrentUserName(data.Name);
      setCurrentUserId(data.ID);
    };

    const fetchBalances = async () => {
      const res = await fetch(`http://localhost:5001/api/groups/${groupId}/balances`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      const data = await res.json();
      setBalances(data);
    };

    const fetchExpenses = async () => {
      const res = await fetch(`http://localhost:5001/api/groups/${groupId}/expenses`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      const data = await res.json();
      if (res.ok) {
        setExpenses(data.expenses || []);
        setSettlements(data.settlements || []);
      } else {
        alert(data.error || 'Failed to fetch group details');
      }
    };

    const fetchGroupMembers = async () => {
        const token = localStorage.getItem('token');
        const res = await fetch(`http://localhost:5001/api/groups/${groupId}/members`, {
            headers: { Authorization: `Bearer ${token}` }
        });
        const data = await res.json();
        if (res.ok) {
            setGroupMembers(data || []);
        } else {
            alert(data.error || 'Failed to fetch group members');
        }
    };

    fetchUser();
    fetchBalances();
    fetchExpenses();
    fetchGroupMembers();
  }, [groupId]);

  const owes = balances.filter(b => b.from === currentUserName);
  const owedToYou = balances.filter(b => b.to === currentUserName);

  // Refresh balances and expenses after mutation
  const refreshData = async () => {
    const token = localStorage.getItem('token');
    const resBalances = await fetch(`http://localhost:5001/api/groups/${groupId}/balances`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    const balancesData = await resBalances.json();
    setBalances(balancesData);

    const resExpenses = await fetch(`http://localhost:5001/api/groups/${groupId}/expenses`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    const expensesData = await resExpenses.json();
    setExpenses(expensesData.expenses || []);
    setSettlements(expensesData.settlements || []);
  };

  // Handle add expense submit
  const handleAddExpense = async () => {
    if (!expenseName || !expenseAmount || !expensePaidBy) {
      alert('Please fill all required expense fields');
      return;
    }
    const token = localStorage.getItem('token');
    try {
      const res = await fetch(`http://localhost:5001/api/groups/${groupId}/expenses`, {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`
        },
        body: JSON.stringify({
          name: expenseName,
          description: expenseDescription,
          amount: parseFloat(expenseAmount),
          paid_by: expensePaidBy
        })
      });
      const data = await res.json();
      if (!res.ok) {
        alert(data.error || 'Failed to add expense');
      } else {
        alert('Expense added!');
        setShowExpenseForm(false);
        setExpenseName('');
        setExpenseDescription('');
        setExpenseAmount('');
        setExpensePaidBy(null);
        refreshData();
      }
    } catch (e) {
      alert('Error adding expense');
    }
  };

  // Handle add settlement submit
  const handleAddSettlement = async () => {
    if (!settleFromUser || !settleToUser || !settleAmount) {
      alert('Please fill all required settlement fields');
      return;
    }
    if (settleFromUser === settleToUser) {
      alert('From and To users must be different');
      return;
    }
    const token = localStorage.getItem('token');
    try {
      const res = await fetch(`http://localhost:5001/api/groups/${groupId}/settle`, {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`
        },
        body: JSON.stringify({
          from_user_id: settleFromUser,
          to_user_id: settleToUser,
          amount: parseFloat(settleAmount)
        })
      });
      const data = await res.json();
      if (!res.ok) {
        alert(data.error || 'Failed to add settlement');
      } else {
        alert('Settlement added!');
        setShowSettlementForm(false);
        setSettleFromUser(null);
        setSettleToUser(null);
        setSettleAmount('');
        refreshData();
      }
    } catch (e) {
      alert('Error adding settlement');
    }
  };

  // Create a combined sorted list of expenses and settlements newest first
  const combinedActivity = [...expenses.map(e => ({ ...e, type: 'expense' })), 
                            ...settlements.map(s => ({ ...s, type: 'settlement' }))];
  combinedActivity.sort((a, b) => new Date(b.CreatedAt) - new Date(a.CreatedAt));

return (
  <>
    {/* Top Header with Action Buttons */}
    <div className="flex justify-between items-center p-8 bg-gray-100">
      <h1 className="text-3xl font-bold text-gray-800">{groupName || 'Group Summary'}</h1>
      <div className="space-x-2">
        <button
          onClick={() => setShowExpenseForm(true)}
          className="bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded font-semibold"
        >
          + Add Expense
        </button>
        <button
          onClick={() => setShowSettlementForm(true)}
          className="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded font-semibold"
        >
          + Add Settlement
        </button>
      </div>
    </div>

    {/* Main Content Section */}
    <div className="flex gap-8 p-8 bg-gray-100 min-h-screen">
      {/* Left Panel: Balances */}
      <div className="w-1/2 bg-white p-6 rounded shadow">
        <h2 className="text-2xl font-bold mb-6 text-indigo-700">Your Balances</h2>

        {/* You Owe Section */}
        <div className="mb-8">
          <h3 className="text-lg font-semibold text-indigo-600 mb-3 flex items-center">
            <span className="w-3 h-3 bg-indigo-500 rounded-full mr-2"></span> You owe
          </h3>
          {owes.length > 0 ? owes.map((item, i) => (
            <div
              key={i}
              className="flex justify-between items-center bg-indigo-50 px-4 py-2 rounded-md mb-2 hover:bg-indigo-100 transition"
            >
              <span className="text-gray-700">
                You owe <span className="font-medium text-indigo-700">{item.to}</span>
              </span>
              <span className="font-bold text-indigo-900">${item.amount.toFixed(2)}</span>
            </div>
          )) : (
            <p className="text-sm text-gray-500">You owe nothing.</p>
          )}
        </div>

        {/* Owes You Section */}
        <div>
          <h3 className="text-lg font-semibold text-green-600 mb-3 flex items-center">
            <span className="w-3 h-3 bg-green-500 rounded-full mr-2"></span> Owes you
          </h3>
          {owedToYou.length > 0 ? owedToYou.map((item, i) => (
            <div
              key={i}
              className="flex justify-between items-center bg-green-50 px-4 py-2 rounded-md mb-2 hover:bg-green-100 transition"
            >
              <span className="text-gray-700">
                <span className="font-medium text-green-700">{item.from}</span> owes you
              </span>
              <span className="font-bold text-green-900">${item.amount.toFixed(2)}</span>
            </div>
          )) : (
            <p className="text-sm text-gray-500">No one owes you.</p>
          )}
        </div>
      </div>

      {/* Right Panel: Group Activity */}
      <div className="w-1/2 bg-white p-6 rounded shadow">
        <h2 className="text-2xl font-bold text-indigo-700 mb-6">Group Activity</h2>

        {/* Activity list */}
        <div className="space-y-6 max-h-[60vh] overflow-y-auto">
          {combinedActivity.length > 0 ? combinedActivity.map((item, i) => (
            <div
              key={i}
              className="border-l-4 pl-4 relative group hover:bg-gray-50 transition-colors duration-200 rounded"
              style={{ borderColor: item.type === 'expense' ? '#6366f1' : '#10b981' }}
            >
              <span className={`absolute -left-2 top-2 w-4 h-4 rounded-full ${item.type === 'expense' ? 'bg-indigo-500' : 'bg-green-500'}`}></span>

              {item.type === 'expense' ? (
                <>
                  <div className="text-sm text-indigo-800 font-semibold">{item.Name}</div>
                  {item.Description && (
                    <div className="text-xs italic text-gray-500 mb-1">{item.Description}</div>
                  )}
                  <div className="text-sm text-gray-700">
                    Paid by <span className="font-semibold text-indigo-600">{item.PaidByName}</span> • 
                    <span className="text-gray-900 font-bold ml-1">${parseFloat(item.Amount).toFixed(2)}</span>
                  </div>
                </>
              ) : (
                <div className="text-sm text-gray-700">
                  <span className="font-semibold text-green-600">{item.FromName}</span> paid 
                  <span className="font-semibold text-green-600 mx-1">{item.ToName}</span>
                  <span className="text-gray-900 font-bold">${parseFloat(item.Amount).toFixed(2)}</span>
                </div>
              )}

              <div className="text-xs text-gray-400 mt-1">
                {new Date(item.CreatedAt).toLocaleString()}
              </div>
            </div>
          )) : (
            <p className="text-sm text-gray-500">No group activity yet.</p>
          )}
        </div>
      </div>
    </div>

    {/* Add Expense Modal */}
    {showExpenseForm && (
      <div className="fixed inset-0 bg-black bg-opacity-30 flex justify-center items-center z-50">
        <div className="bg-white rounded p-6 w-full max-w-md">
          <h3 className="text-xl font-semibold mb-4 text-indigo-700">Add Expense</h3>
          <input
            type="text"
            placeholder="Name"
            className="w-full mb-3 p-2 border rounded"
            value={expenseName}
            onChange={e => setExpenseName(e.target.value)}
          />
          <input
            type="text"
            placeholder="Description (optional)"
            className="w-full mb-3 p-2 border rounded"
            value={expenseDescription}
            onChange={e => setExpenseDescription(e.target.value)}
          />
          <input
            type="number"
            placeholder="Amount"
            className="w-full mb-3 p-2 border rounded"
            value={expenseAmount}
            onChange={e => setExpenseAmount(e.target.value)}
            min="0"
            step="0.01"
          />
          <select
            className="w-full mb-4 p-2 border rounded"
            value={expensePaidBy || ''}
            onChange={e => setExpensePaidBy(Number(e.target.value))}
          >
            <option value="" disabled>Select who paid</option>
            {groupMembers.map((member) => (
              <option key={member.ID} value={member.ID}>
                {member.Name}
              </option>
            ))}
          </select>

          <div className="flex justify-end space-x-4">
            <button onClick={() => setShowExpenseForm(false)} className="px-4 py-2 rounded border">Cancel</button>
            <button onClick={handleAddExpense} className="bg-indigo-600 text-white px-4 py-2 rounded">Add</button>
          </div>
        </div>
      </div>
    )}

    {/* Add Settlement Modal */}
    {showSettlementForm && (
      <div className="fixed inset-0 bg-black bg-opacity-30 flex justify-center items-center z-50">
        <div className="bg-white rounded p-6 w-full max-w-md">
          <h3 className="text-xl font-semibold mb-4 text-green-700">Add Settlement</h3>
          <select
            className="w-full mb-3 p-2 border rounded"
            value={settleFromUser || ''}
            onChange={e => setSettleFromUser(Number(e.target.value))}
          >
            <option value="" disabled>Select payer</option>
            {groupMembers.map((member) => (
              <option key={member.ID} value={member.ID}>
                {member.Name}
              </option>
            ))}
          </select>

          <select
            className="w-full mb-3 p-2 border rounded"
            value={settleToUser || ''}
            onChange={e => setSettleToUser(Number(e.target.value))}
          >
            <option value="" disabled>Select payee</option>
            {groupMembers.map((member) => (
              <option key={member.ID} value={member.ID}>
                {member.Name}
              </option>
            ))}
          </select>

          <input
            type="number"
            placeholder="Amount"
            className="w-full mb-4 p-2 border rounded"
            value={settleAmount}
            onChange={e => setSettleAmount(e.target.value)}
            min="0"
            step="0.01"
          />
          <div className="flex justify-end space-x-4">
            <button onClick={() => setShowSettlementForm(false)} className="px-4 py-2 rounded border">Cancel</button>
            <button onClick={handleAddSettlement} className="bg-green-600 text-white px-4 py-2 rounded">Add</button>
          </div>
        </div>
      </div>
    )}
  </>
);

}

export default GroupDetailsPage;
