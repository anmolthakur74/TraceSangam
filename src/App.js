// src/App.js
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Sidebar from "./components/Sidebar";
import Topbar from "./components/Topbar";
import Dashboard from "./components/Dashboard"; 
import ShipmentsPage from './pages/ShipmentsPage'; 
export default function App() {
  return (
    <Router>
      <div className="flex">
        <Sidebar />
        <div className="ml-64 flex-1 bg-gray-50 min-h-screen">
          <Topbar />
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/shipments" element={<ShipmentsPage />} />
          </Routes>
        </div>
      </div>
    </Router>
  );
}
