// src/components/Topbar.js

import { FiBell, FiSearch, FiUser } from 'react-icons/fi';

export default function Topbar() {
  return (
    <div className="flex items-center justify-between p-4 bg-white shadow-sm border-b sticky top-0 z-50">
      {/* Search Box */}
      <div className="w-full max-w-md relative">
        <FiSearch className="absolute top-2.5 left-3 text-gray-400" />
        <input
          type="text"
          placeholder="Track by Box ID or Product Name"
          className="w-full pl-10 pr-4 py-2 rounded border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>

      {/* Icons */}
      <div className="flex items-center space-x-4">
        <FiBell className="text-gray-600 hover:text-blue-600 cursor-pointer" size={20} />
        <FiUser className="text-gray-600 hover:text-blue-600 cursor-pointer" size={20} />
      </div>
    </div>
  );
}
