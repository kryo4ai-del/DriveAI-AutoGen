module.exports = {
  content: ['./src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        'factory-bg': '#0a0a1a',
        'factory-surface': '#141428',
        'factory-surface-hover': '#1c1c38',
        'factory-border': '#2a2a45',
        'factory-accent': '#00e5a0',
        'factory-accent-blue': '#00b8ff',
        'factory-success': '#22c55e',
        'factory-warning': '#eab308',
        'factory-error': '#ef4444',
        'factory-text': '#e8e8f0',
        'factory-text-secondary': '#8888a0',
      },
      animation: {
        'pulse-gold': 'pulseGold 2s ease-in-out infinite',
        'blink-red': 'blinkRed 1.5s ease-in-out infinite',
      },
      keyframes: {
        pulseGold: {
          '0%, 100%': { boxShadow: '0 0 0 0 rgba(234, 179, 8, 0)' },
          '50%': { boxShadow: '0 0 20px 4px rgba(234, 179, 8, 0.3)' },
        },
        blinkRed: {
          '0%, 100%': { boxShadow: '0 0 0 0 rgba(239, 68, 68, 0)' },
          '50%': { boxShadow: '0 0 20px 4px rgba(239, 68, 68, 0.4)' },
        },
      },
    },
  },
  plugins: [],
};
