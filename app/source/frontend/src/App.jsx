import React from 'react';
import HabitTracker from './components/HabitTracker';
import { ThemeProvider } from 'styled-components';

const theme = {
  colors: {
    primary: '#4361ee',
    secondary: '#3f37c9',
    success: '#4cc9f0',
    background: '#f8f9fa',
    text: '#1a1a1a',
    lightGray: '#f0f2f5',
  },
  spacing: {
    small: '0.5rem',
    medium: '1rem',
    large: '2rem',
  },
  borderRadius: '8px',
};

function App() {
  return (
    <ThemeProvider theme={theme}>
      <HabitTracker />
    </ThemeProvider>
  );
}

export default App;