// app-repo/source/backend/src/server.js
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const config = require('./config');

const app = express();
app.use(cors());
app.use(express.json());

const pool = new Pool(config.db);

// Add health check endpoint for Kubernetes
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

// Rest of the endpoints remain the same...