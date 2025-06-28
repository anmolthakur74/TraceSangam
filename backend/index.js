const express = require('express');
const fs = require('fs');
const path = require('path');
const bcrypt = require('bcrypt');

const app = express();
const PORT = process.env.PORT || 3001;

const DATA_FILE = path.join(__dirname, 'data', 'products.json');
const USERS_FILE = path.join(__dirname, 'data', 'users.json');

// Middleware
app.use(express.json());
app.use(express.static(path.join(__dirname, 'frontend')));

// Serve main HTML page
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'frontend', 'index.html'));
});

// 🚀 Get all products
app.get('/getAllProducts', (req, res) => {
  try {
    let products = [];
    if (fs.existsSync(DATA_FILE)) {
      const data = fs.readFileSync(DATA_FILE, 'utf8');
      products = data.length ? JSON.parse(data) : [];
    }
    return res.json(products);
  } catch (err) {
    return res.status(500).json({ error: 'Failed to load products', message: err.message });
  }
});

// Add product
app.post('/addProduct', (req, res) => {
  console.time("AddProduct");
  const { farmerName, crop, location, date } = req.body;

  if (!farmerName || !crop || !location || !date) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  const batchId = Math.random().toString(36).substring(2, 10);
  const newProduct = {
    batchId,
    farmerName,
    crop,
    location,
    date,
    timestamp: new Date().toISOString()
  };

  try {
    let products = [];
    if (fs.existsSync(DATA_FILE)) {
      const data = fs.readFileSync(DATA_FILE);
      products = data.length ? JSON.parse(data) : [];
    }

    products.push(newProduct);
    fs.writeFileSync(DATA_FILE, JSON.stringify(products, null, 2));

    res.status(201).json({ message: "Product added", batchId });
  } catch (err) {
    res.status(500).json({ error: "Failed to save product", message: err.message });
  }

  console.timeEnd("AddProduct");
});

// Get trace by batchId
app.get('/getTrace/:batchId', (req, res) => {
  console.time("GetTrace");
  const batchId = req.params.batchId;

  try {
    let products = [];
    if (fs.existsSync(DATA_FILE)) {
      const data = fs.readFileSync(DATA_FILE, 'utf8');
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

// ✅ USER AUTH - Read Users Helper
function readUsers() {
  if (!fs.existsSync(USERS_FILE)) return [];
  const raw = fs.readFileSync(USERS_FILE, 'utf-8');
  return raw.length ? JSON.parse(raw) : [];
}

// ✅ Signup Route
app.post('/api/signup', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) return res.status(400).json({ message: 'Email and password required' });

  const users = readUsers();
  const existing = users.find(u => u.email === email);
  if (existing) return res.status(400).json({ message: 'User already exists' });

  const hashedPassword = await bcrypt.hash(password, 10);
  users.push({ email, password: hashedPassword });

  fs.writeFileSync(USERS_FILE, JSON.stringify(users, null, 2));
  res.status(201).json({ message: 'Signup successful', email });
});

// ✅ Login Route
app.post('/api/login', async (req, res) => {
  const { email, password } = req.body;

  const users = readUsers();
  const user = users.find(u => u.email === email);
  if (!user) return res.status(401).json({ message: 'Invalid credentials' });

  const isMatch = await bcrypt.compare(password, user.password);
  if (!isMatch) return res.status(401).json({ message: 'Invalid credentials' });

  res.status(200).json({ message: 'Login successful', email });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running at http://localhost:${PORT}`);
});
