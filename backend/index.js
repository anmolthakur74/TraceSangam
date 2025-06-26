const express = require('express');
const QRCode = require('qrcode');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 3001;
const DATA_FILE = path.join(__dirname, 'data', 'products.json');

app.use(express.json());

app.get('/test', (req, res) => {
  console.log("/test route working");
  res.send("Test route working!");
});
console.time("AddProduct");
app.post('/addProduct', async (req, res) => {
  console.log("Product added");

  const { farmerName, crop, location, date } = req.body;

  if (!farmerName || !crop || !location || !date) {
    console.log("Missing fields");
    return res.status(400).json({ error: 'Missing required fields' });
  }

  const batchId = Math.random().toString(36).substring(2, 10);
  console.log("Batch ID:", batchId);

  const newProduct = {
    batchId,
    farmerName,
    crop,
    location,
    date,
    timestamp: new Date().toISOString()
  };

  try {
    // Load existing products
    let products = [];
    if (fs.existsSync(DATA_FILE)) {
      const data = fs.readFileSync(DATA_FILE);
      products = data.length ? JSON.parse(data) : [];
    }

    products.push(newProduct);
    fs.writeFileSync(DATA_FILE, JSON.stringify(products, null, 2));

    console.log("Product saved");

    res.status(201).json({
      message: "Product added",
      batchId
    });
  } catch (err) {
    console.error("Error saving product:", err);
    res.status(500).json({
      error: "Failed to save product",
      message: err.message
    });
  }
});

app.get('/getTrace/:batchId', (req, res) => {
  console.time("GetTrace");

  const batchId = req.params.batchId;
  console.log("🔍 GET trace for:", batchId);

  try {
    let products = [];
    if (fs.existsSync(DATA_FILE)) {
      const data = fs.readFileSync(DATA_FILE, 'utf8'); // <- force UTF-8 read
      products = data.length ? JSON.parse(data) : [];
    }

    const product = products.find(p => p.batchId === batchId);

    console.timeEnd("GetTrace");

    if (!product) {
      return res.status(404).json({ error: 'Batch not found' });
    }

    return res.json(product);
  } catch (err) {
    console.error("❌ Error in getTrace:", err.message);
    return res.status(500).json({ error: 'Server error', message: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
