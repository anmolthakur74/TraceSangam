// src/pages/ShipmentsPage.js
import { FiSearch, FiEye, FiDownload } from 'react-icons/fi';

const shipments = [
  {
    id: 'BX001',
    product: 'Organic Basmati Rice',
    weight: '25 tons',
    origin: 'Nashik, India',
    destination: 'Hamburg, Germany',
    status: 'At Port',
    compliance: 'Compliant',
    eta: '2024-01-15',
    value: '$45,000',
  },
  {
    id: 'BX002',
    product: 'Alphonso Mangoes',
    weight: '15 tons',
    origin: 'Ratnagiri, India',
    destination: 'Rotterdam, Netherlands',
    status: 'In Transit',
    compliance: 'Compliant',
    eta: '2024-01-18',
    value: '$32,000',
  },
  {
    id: 'BX003',
    product: 'Darjeeling Tea',
    weight: '5 tons',
    origin: 'Darjeeling, India',
    destination: 'London, UK',
    status: 'Delivered',
    compliance: 'Compliant',
    eta: '2024-01-10',
    value: '$28,000',
  },
];

export default function ShipmentsPage() {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Shipments Management</h1>

      {/* Filters */}
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center space-x-2">
          <div className="relative">
            <FiSearch className="absolute top-2.5 left-3 text-gray-400" />
            <input
              type="text"
              placeholder="Search shipments..."
              className="pl-10 pr-4 py-2 rounded border border-gray-300 focus:ring-blue-500 focus:outline-none"
            />
          </div>

          <select className="border px-4 py-2 rounded text-sm text-gray-600">
            <option>All Status</option>
            <option>At Port</option>
            <option>In Transit</option>
            <option>Delivered</option>
          </select>

          <select className="border px-4 py-2 rounded text-sm text-gray-600">
            <option>All Compliance</option>
            <option>Compliant</option>
            <option>Non-Compliant</option>
          </select>
        </div>

        <button className="bg-blue-600 text-white px-4 py-2 rounded flex items-center space-x-2 hover:bg-blue-700">
          <FiDownload />
          <span>Export</span>
        </button>
      </div>

      {/* Table */}
      <div className="bg-white shadow-sm rounded overflow-hidden">
        <div className="p-4 font-semibold text-lg border-b">All Shipments ({shipments.length})</div>
        <table className="w-full text-sm">
          <thead className="text-left text-gray-500 bg-gray-100">
            <tr>
              <th className="p-4">Shipment ID</th>
              <th>Product</th>
              <th>Origin → Destination</th>
              <th>Status</th>
              <th>Compliance</th>
              <th>ETA</th>
              <th>Value</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {shipments.map((s) => (
              <tr key={s.id} className="border-t hover:bg-gray-50">
                <td className="p-4">{s.id}</td>
                <td>
                  <div className="font-medium">{s.product}</div>
                  <div className="text-gray-400 text-xs">{s.weight}</div>
                </td>
                <td className="text-sm">
                  {s.origin} <span className="text-gray-400">→</span> {s.destination}
                </td>
                <td>
                  <span
                    className={`px-2 py-1 rounded-full text-xs font-medium ${
                      s.status === 'Delivered'
                        ? 'bg-green-100 text-green-700'
                        : s.status === 'In Transit'
                        ? 'bg-blue-100 text-blue-600'
                        : 'bg-yellow-100 text-yellow-700'
                    }`}
                  >
                    {s.status}
                  </span>
                </td>
                <td>
                  <span className="px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-700">
                    {s.compliance}
                  </span>
                </td>
                <td>{s.eta}</td>
                <td>{s.value}</td>
                <td className="space-x-2 text-gray-600">
                  <button title="View"><FiEye /></button>
                  <button title="Download"><FiDownload /></button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
