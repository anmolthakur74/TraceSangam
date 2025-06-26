# 🌾 TraceSangam

**Reimagining agricultural export traceability using QR codes and blockchain.**

TraceSangam is a prototype solution that allows full traceability of agricultural produce — from the farmer to the final exporter. The system uses a mobile app for data capture, a backend for batch processing, QR codes for product tracking, and a dashboard to visualize the entire supply chain. A simulated blockchain ensures data integrity and trustworthiness.

---

## 🔍 Problem

India's agricultural export sector faces major traceability challenges:
- No reliable way to verify where crops come from
- Paper-based records are easily tampered with
- Rejections due to lack of transparency hurt both farmers and exporters

---

## 💡 Our Solution

TraceSangam creates a transparent farm-to-export tracking system by:
- Capturing crop data from the farmer at the source
- Generating a QR code per batch with all trace data
- Allowing exporters and importers to view a verified crop journey
- Storing the trace data securely via a simulated blockchain ledger

---

## 🛠️ Tech Stack

| Module            | Technology            |
|------------------|------------------------|
| Mobile App        | Flutter (Dart)         |
| Backend API       | Node.js, Express.js    |
| Frontend Dashboard| React.js (Vercel)      |
| QR Code Gen       | `qrcode` (Node.js)     |
| Blockchain Sim    | JSON log / Hyperledger Fabric (optional) |
| Hosting           | Vercel (frontend), Render / Localhost (backend) |

---

## 📲 Features

### ✅ Farmer App
- Simple Flutter UI to collect:
  - Farmer name
  - Crop type
  - Location
  - Harvest date
- Submits data to backend
- Displays generated QR code

### ✅ Backend API
- Accepts data from app (`/addProduct`)
- Generates unique batch ID + QR
- Returns QR to frontend
- Exposes trace info via `/getTrace/:batchId`

### ✅ React Dashboard
- Enter or scan a batch ID
- Fetch and display:
  - Crop details
  - Farmer info
  - QR code
  - Product journey (steps)
- Deployed via Vercel

### ✅ Blockchain Trace (Simulated)
- Fake blockchain ledger using JSON logs
- Logs: Farmer → Agent → Transporter → Exporter
- Optional: Setup Hyperledger Fabric for demo

---

## 📈 User Flow

1. **Farmer** enters crop details using mobile app  
2. **Backend** receives data, creates `batchId`, generates QR  
3. QR is printed or shown on packaging  
4. **Buyers or inspectors** scan QR on dashboard  
5. Full trace from farm to export is displayed

---

## 🔐 Future Scope

- Real-time blockchain integration via Hyperledger Fabric  
- Exporter/admin login & approval flows  
- SMS / WhatsApp notification to farmers  
- Detailed analytics dashboard for government/export bodies  
- Cloud-hosted DB and image storage (S3/Firebase)

---



