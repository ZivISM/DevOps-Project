// app-repo/source/backend/src/server.js
import express, { json } from 'express';
import cors from 'cors';
import pkg from 'pg';
const { Pool } = pkg;
import { config } from './config.js';

console.log('Environment SERVER_PORT:', process.env.SERVER_PORT);
console.log('Config server port:', config.server.port);

const SERVER_PORT = config.server.port;
console.log('Final SERVER_PORT:', SERVER_PORT);
const app = express();

// Simpler CORS configuration
app.use(cors({
  origin: '*',  // Allow all origins for development
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(json());

const pool = new Pool(config.db);

// Add health check endpoint for Kubernetes
app.get('/api/habits', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM habits ORDER BY id ASC');
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching habits:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.post('/api/habits', async (req, res) => {
  const { name } = req.body;
  
  // Basic validation
  if (!name || name.trim() === '') {
    return res.status(400).json({ error: 'Habit name is required' });
  }

  try {
    const result = await pool.query(
      'INSERT INTO habits (name, completed) VALUES ($1, $2) RETURNING *',
      [name, false] // Set completed to false by default
    );
    
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error creating habit:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Add health check endpoint for Kubernetes
app.get('/api/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

// Add readiness check endpoint for Kubernetes
app.get('/api/ready', async (req, res) => {
  try {
    // Test database connection
    await pool.query('SELECT 1');
    res.status(200).json({ status: 'ready' });
  } catch (error) {
    console.error('Readiness check failed:', error);
    res.status(500).json({ status: 'not ready', error: error.message });
  }
});

// Remove the base URL since it will be handled by the ingress
app.use('/habits', habitsRouter);  // This will be accessible at /api/habits

const port = process.env.PORT || 5000;
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
