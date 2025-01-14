// app-repo/source/frontend/src/components/HabitTracker.jsx
import React, { useState, useEffect } from 'react';
import { PlusCircle, CheckCircle, Circle } from 'lucide-react';
import axios from 'axios';

const HabitTracker = () => {
  const [habits, setHabits] = useState([]);
  const [newHabit, setNewHabit] = useState('');

  // Fetch habits from backend
  useEffect(() => {
    const fetchHabits = async () => {
      try {
        const response = await axios.get('http://localhost:5000/api/habits');
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
      const response = await axios.post('http://localhost:5000/api/habits', {
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
      const response = await axios.put(`http://localhost:5000/api/habits/${id}`, {
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
    <div className="min-h-screen bg-gray-50 p-8">
      <div className="max-w-2xl mx-auto">
        <h1 className="text-4xl font-bold text-gray-800 mb-8">Daily Habits</h1>
        
        <form onSubmit={addHabit} className="mb-8">
          <div className="flex gap-4">
            <input
              type="text"
              value={newHabit}
              onChange={(e) => setNewHabit(e.target.value)}
              placeholder="Add a new habit..."
              className="flex-1 rounded-lg border border-gray-200 px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
            <button
              type="submit"
              className="bg-blue-500 text-white rounded-lg px-6 py-2 hover:bg-blue-600 transition-colors flex items-center gap-2"
            >
              <PlusCircle size={20} />
              Add
            </button>
          </div>
        </form>

        <div className="space-y-4">
          {habits.map(habit => (
            <div
              key={habit.id}
              className="bg-white rounded-lg p-6 shadow-sm hover:shadow-md transition-shadow"
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-4">
                  <button
                    onClick={() => toggleHabit(habit.id)}
                    className="text-blue-500 hover:text-blue-600 transition-colors"
                  >
                    {habit.completed ? (
                      <CheckCircle size={24} className="text-green-500" />
                    ) : (
                      <Circle size={24} />
                    )}
                  </button>
                  <div>
                    <h3 className="text-lg font-semibold text-gray-800">
                      {habit.name}
                    </h3>
                    <p className="text-sm text-gray-500">
                      Current streak: {habit.streak} days
                    </p>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default HabitTracker;