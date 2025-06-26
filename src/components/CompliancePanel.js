// src/components/CompliancePanel.js
export default function CompliancePanel() {
  return (
    <div className="bg-white p-4 shadow rounded border">
      <h2 className="text-lg font-semibold mb-2">System Status</h2>
      <p className="text-green-600 font-bold text-xl">✅ 96.1% Compliant</p>
      <p className="text-xs text-gray-500 mt-1">Last Check: 2 hours ago</p>
      <p className="text-xs text-red-500 mt-1">Active Alerts: 6</p>
      <button className="mt-3 px-4 py-2 bg-blue-600 text-white rounded">Download Report</button>
    </div>
  );
}
