module.exports = {
  content: ['./src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        'factory-bg': '#13121A',
        'factory-surface': '#1E1D25',
        'factory-surface-hover': '#2a2935',
        'factory-border': '#3a3950',
        'factory-accent': '#D660D7',
        'factory-accent-blue': '#6BD2F2',
        'factory-accent-glow': '#F09CF8',
        'factory-purple': '#7A3C9F',
        'factory-success': '#22c55e',
        'factory-warning': '#eab308',
        'factory-error': '#ef4444',
        'factory-text': '#FFFFFF',
        'factory-text-secondary': '#B0B0C0',
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
