const express = require('express');
const mongoose = require('mongoose');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware to handle JSON payloads and serve static frontend files
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Fallback MongoDB URI for local testing before shifting to Docker
const mongoURI = process.env.MONGO_URI || 'mongodb://localhost:27017/assetdb';

// Connect to MongoDB with automated retry logic
mongoose.connect(mongoURI)
    .then(() => console.log('Successfully connected to MongoDB.'))
    .catch((err) => console.error('MongoDB initial connection error:', err));

// Define a simple Database Schema
const AssetSchema = new mongoose.Schema({
    name: { type: String, required: true },
    status: { type: String, required: true },
    createdAt: { type: Date, default: Date.now }
});

const Asset = mongoose.model('Asset', AssetSchema);

// API Route: Get all assets
app.get('/api/assets', async (req, res) => {
    try {
        const assets = await Asset.find().sort({ createdAt: -1 });
        res.json(assets);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch assets from database.' });
    }
});

// API Route: Add a new asset
app.post('/api/assets', async (req, res) => {
    try {
        const { name, status } = req.body;
        if (!name || !status) {
            return res.status(400).json({ error: 'Name and status are required.' });
        }
        const newAsset = new Asset({ name, status });
        await newAsset.save();
        res.status(201).json(newAsset);
    } catch (error) {
        res.status(500).json({ error: 'Failed to save asset to database.' });
    }
});

// Start Server explicitly bound to all network interfaces for Docker
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Backend server is bound to 0.0.0.0 and listening on port ${PORT}`);
});