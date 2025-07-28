import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import LoginPage from './pages/LoginPage';
import SignupPage from './pages/SignupPage';
import DashboardPage from './pages/DashboardPage';
import GroupsPage from './pages/GroupsPage';
import SummaryPage from './pages/SummaryPage';
import CreateGroupPage from './pages/CreateGroupPage';
import GroupDetailsPage from './pages/GroupDetailsPage';
import FriendsPage from './pages/FriendsPage';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/signup" element={<SignupPage />} />
        <Route path="/dashboard" element={<DashboardPage />} />
        <Route path="/groups" element={<GroupsPage />} />
        <Route path="/summary" element={<SummaryPage />} />
        <Route path="/create-group" element={<CreateGroupPage />} />
        <Route path="/groups/:groupId" element={<GroupDetailsPage />} />
        <Route path="/friends" element={<FriendsPage />} />
      </Routes>
    </Router>
  );
}

export default App;
