// src/components/Sidebar.js
import { FiBox, FiSettings, FiBell, FiBarChart2 } from 'react-icons/fi';

export default function Sidebar() {
  return (
    <div className="w-64 bg-white border-r h-screen p-4 fixed">
      <h1 className="text-xl font-bold mb-6">Blocksangam</h1>
      <nav className="space-y-4">
        {[
          { name: 'Dashboard', icon: FiBarChart2 },
          { name: 'Products', icon: FiBox },
          { name: 'QR/Barcode Lookup', icon: FiBarChart2 },
          { name: 'Alerts / Tamper Events', icon: FiBell },
          { name: 'Settings', icon: FiSettings }
        ].map(({ name, icon: Icon }) => (
          <div key={name} className="flex items-center space-x-3 text-gray-700 hover:text-blue-600 cursor-pointer">
            <Icon />
            <span>{name}</span>
          </div>
        ))}
      </nav>
    </div>
  );
}

