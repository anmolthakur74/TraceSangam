// src/components/Shipments.js
const shipments = [
  {
    id: 'BX001',
    product: 'Organic Basmati Rice',
    location: 'Nashik, India',
    eta: '2024-01-15',
    temp: '22°C',
    status: 'At Port',
  },
  {
    id: 'BX002',
    product: 'Alphonso Mangoes',
    location: 'Ratnagiri, India',
    eta: '2024-01-18',
    temp: '18°C',
    status: 'In Transit',
  },
  {
    id: 'BX003',
    product: 'Darjeeling Tea',
    location: 'Darjeeling, India',
    eta: '2024-01-10',
    temp: '25°C',
    status: 'Delivered',
  },
];

export default function Shipments() {
  return (
    <div>
      <h2 className="font-semibold mb-4 text-lg">Recent Shipments</h2>
      <div className="space-y-4">
        {shipments.map((item) => (
          <div key={item.id} className="p-4 border rounded flex justify-between items-center bg-white shadow-sm">
            <div>
              <div className="font-semibold">{item.product}</div>
              <div className="text-sm text-gray-500">Box ID: {item.id}</div>
              <div className="text-xs text-gray-400">{item.location} · ETA: {item.eta} · {item.temp}</div>
            </div>
            <div className="text-right text-sm">
              <div className="rounded-full bg-blue-100 text-blue-600 px-3 py-1 inline-block">{item.status}</div>
              <div className="text-xs text-green-600 mt-1">Secure</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
