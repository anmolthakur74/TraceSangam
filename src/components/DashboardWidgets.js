// src/components/DashboardWidgets.js
export default function DashboardWidgets() {
  const stats = [
    { label: 'Total Shipments', value: 3 },
    { label: 'Compliant', value: 3 },
    { label: 'In Transit', value: 2 },
    { label: 'Alerts', value: 6, color: 'bg-red-100 text-red-600' },
  ];
  return (
    <div className="grid grid-cols-4 gap-4 mb-6">
      {stats.map(({ label, value, color }) => (
        <div key={label} className={`p-4 rounded shadow ${color || 'bg-white'} border`}>
          <div className="text-sm text-gray-500">{label}</div>
          <div className="text-xl font-bold">{value}</div>
        </div>
      ))}
    </div>
  );
}
