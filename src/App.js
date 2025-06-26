// src/App.js
import Sidebar from "./components/Sidebar";
import Topbar from "./components/Topbar"; // 
import DashboardWidgets from "./components/DashboardWidgets";
import Shipments from "./components/Shipments";
import CompliancePanel from "./components/CompliancePanel";

export default function App() {
  return (
    <div className="flex">
      <Sidebar />
      <div className="ml-64 flex-1 bg-gray-50 min-h-screen">
        <Topbar /> 
        <div className="p-6">
          <DashboardWidgets />
          <div className="grid grid-cols-3 gap-4">
            <div className="col-span-2">
              <Shipments />
            </div>
            <CompliancePanel />
          </div>
        </div>
      </div>
    </div>
  );
}
