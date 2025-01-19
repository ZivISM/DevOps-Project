// app-repo/source/frontend/src/components/HabitTracker.jsx
import React, { useState, useEffect } from 'react';
import { PlusCircle, CheckCircle, Circle } from 'lucide-react';
import axios from 'axios';
import styled from 'styled-components';

// Use window.location.hostname to determine environment
const isLocalDevelopment = window.location.hostname === 'localhost';
const API_URL = isLocalDevelopment 
  ? 'http://localhost:5000'  // Use HTTP for local development
  : 'http://habitspace.zivoosh.online/api';

console.log('Using API URL:', API_URL); // For debugging

const client = axios.create({
  baseURL: API_URL
});

const Container = styled.div`
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
  background: #f8f9fa;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
`;

const HabitGrid = styled.div`
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
  margin-top: 2rem;
`;

const HabitCard = styled.div`
  background: white;
  padding: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  transition: transform 0.2s;

  &:hover {
    transform: translateY(-2px);
  }
`;

const Header = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: ${props => props.theme.spacing.large};
`;

const Title = styled.h1`
  font-size: 2rem;
  color: ${props => props.theme.colors.text};
  margin: 0;
`;

const AddHabitForm = styled.form`
  display: flex;
  gap: 1rem;
  margin-bottom: ${props => props.theme.spacing.large};
`;

const Input = styled.input`
  flex: 1;
  padding: 0.75rem 1rem;
  border: 1px solid #e0e0e0;
  border-radius: ${props => props.theme.borderRadius};
  font-size: 1rem;
  
  &:focus {
    outline: none;
    border-color: ${props => props.theme.colors.primary};
    box-shadow: 0 0 0 2px ${props => props.theme.colors.primary}20;
  }
`;

const Button = styled.button`
  background: ${props => props.theme.colors.primary};
  color: white;
  border: none;
  border-radius: ${props => props.theme.borderRadius};
  padding: 0.75rem 1.5rem;
  font-size: 1rem;
  cursor: pointer;
  transition: background-color 0.2s;

  &:hover {
    background: ${props => props.theme.colors.secondary};
  }
`;

const HabitTracker = () => {
  const [habits, setHabits] = useState([]);
  const [newHabit, setNewHabit] = useState('');

  // Fetch habits from backend
  useEffect(() => {
    const fetchHabits = async () => {
      try {
        console.log('Fetching habits');
        
        const response = await client.get(`habits`);
        console.log(response.data);
        
        setHabits(response.data);
      } catch (error) {
        console.error('Error fetching habits:', error);
      }
    };
    fetchHabits();
  }, []);



  // Add new habit
  const addHabit = async (e) => {
    e.preventDefault();
    if (!newHabit.trim()) return;
    
    try {
      const response = await client.post(`habits`, {
        name: newHabit
      });
      setHabits([...habits, response.data]);
      setNewHabit('');
    } catch (error) {
      console.error('Error adding habit:', error);
    } 
  };

  // Toggle habit completion
  const toggleHabit = async (id) => {
    try {
      const habit = habits.find(h => h.id === id);
      const response = await client.put(`habits/${id}`, {
        completed: !habit.completed
      });
      setHabits(habits.map(h => 
        h.id === id ? response.data : h
      ));
    } catch (error) {
      console.error('Error updating habit:', error);
    }
  };

  return (
    <Container>
      <Header>
        <Title>Daily Habits</Title>
      </Header>
      
      <AddHabitForm onSubmit={addHabit}>
        <Input
          type="text"
          value={newHabit}
          onChange={(e) => setNewHabit(e.target.value)}
          placeholder="Add a new habit..."
        />
        <Button type="submit">
          <PlusCircle size={20} style={{ marginRight: '0.5rem' }} />
          Add Habit
        </Button>
      </AddHabitForm>

      <HabitGrid>
        {habits.map(habit => (
          <HabitCard key={habit.id}>
            <div className="flex items-center gap-3">
              <button
                onClick={() => toggleHabit(habit.id)}
                style={{ 
                  background: 'none', 
                  border: 'none',
                  cursor: 'pointer',
                  color: habit.completed ? '#4361ee' : '#94a3b8'
                }}
              >
                {habit.completed ? <CheckCircle size={24} /> : <Circle size={24} />}
              </button>
              <span style={{ 
                color: '#334155',
                textDecoration: habit.completed ? 'line-through' : 'none'
              }}>
                {habit.name}
              </span>
            </div>
          </HabitCard>
        ))}
      </HabitGrid>
    </Container>
  );
};

export default HabitTracker;