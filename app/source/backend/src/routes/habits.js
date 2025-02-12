import express from 'express';
import pkg from 'pg';
const { Pool } = pkg;
import { config } from '../config.js';

const router = express.Router();
const pool = new Pool(config.db);

// GET /habits
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM habits ORDER BY id ASC');
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching habits:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /habits
router.post('/', async (req, res) => {
  const { name } = req.body;
  
  if (!name || name.trim() === '') {
    return res.status(400).json({ error: 'Habit name is required' });
  }

  try {
    const result = await pool.query(
      'INSERT INTO habits (name, completed) VALUES ($1, $2) RETURNING *',
      [name, false]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error creating habit:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PUT /habits/:id
router.put('/:id', async (req, res) => {
  const { id } = req.params;
  const { completed } = req.body;

  try {
    const result = await pool.query(
      'UPDATE habits SET completed = $1 WHERE id = $2 RETURNING *',
      [completed, id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Habit not found' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error updating habit:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router; 
