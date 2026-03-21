// tailwind.config.ts
export default {
  theme: {
    extend: {
      keyframes: {
        'slide-up': {
          '0%': { opacity: '0', transform: 'translateY(16px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        'fade-in': {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
      },
      animation: {
        'slide-up': 'slide-up 0.6s ease-out forwards',
        'fade-in': 'fade-in 0.5s ease-out forwards',
      },
    },
  },
} as const;

// Remove animations.ts or keep as reference only
export const ANIMATION_CLASSES = {
  slideUp: 'animate-slide-up',
  fadeIn: 'animate-fade-in',
} as const;