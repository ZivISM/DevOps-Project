// app-repo/source/backend/src/server.js
import express, { json } from 'express';
import cors from 'cors';
import pkg from 'pg';
const { Pool } = pkg;
import { config } from './config.js';
import habitsRouter from './routes/habits.js';

console.log('Environment SERVER_PORT:', process.env.SERVER_PORT);
console.log('Config server port:', config.server.port);

const SERVER_PORT = config.server.port;
console.log('Final SERVER_PORT:', SERVER_PORT);
const app = express();


app.use(cors({
  origin: '*',  
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(json());

const pool = new Pool(config.db);

// Mount the habits router
app.use('/api/habits', habitsRouter);

// Health check endpoints
app.get('/api/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

app.get('/api/ready', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.status(200).json({ status: 'ready' });
  } catch (error) {
    console.error('Readiness check failed:', error);
    res.status(500).json({ status: 'not ready', error: error.message });
  }
});

const port = process.env.PORT || 5000;
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
