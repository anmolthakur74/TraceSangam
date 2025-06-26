// src/components/Dashboard.js
import DashboardWidgets from "./DashboardWidgets";
import Shipments from "./Shipments";
import CompliancePanel from "./CompliancePanel";

export default function Dashboard() {
  return (
    <div className="p-6">
      <DashboardWidgets />
      <div className="grid grid-cols-3 gap-4">
        <div className="col-span-2">
          <Shipments />
        </div>
        <CompliancePanel />
      </div>
    </div>
  );
}
