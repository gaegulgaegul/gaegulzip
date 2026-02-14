import type { Config } from 'tailwindcss';

export default {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        charcoal: '#2d2d2d',
        cream: '#fff8f0',
        'cream-light': '#fffbf5',
        'cream-dark': '#f5e6d3',
        coral: '#e85d4a',
        'deep-blue': '#2b4c7e',
        mustard: '#f2a541',
        'forest-green': '#4a7c59',
      },
      fontFamily: {
        'nanum-pen': ['var(--font-nanum-pen)'],
        pretendard: ['var(--font-pretendard)'],
      },
      animation: {
        'fade-in': 'fade-in 0.3s ease-in-out',
        'fade-scale': 'fade-scale 0.5s ease-out',
        shake: 'shake 0.5s ease-in-out',
        wiggle: 'wiggle 0.5s ease-in-out',
        fall: 'fall 3s infinite ease-in',
        'spin-slow': 'spin 2s linear infinite',
      },
      keyframes: {
        'fade-in': {
          from: { opacity: '0' },
          to: { opacity: '1' },
        },
        'fade-scale': {
          from: { opacity: '0', transform: 'scale(0.9)' },
          to: { opacity: '1', transform: 'scale(1)' },
        },
        shake: {
          '0%, 100%': { transform: 'rotate(0deg)' },
          '25%': { transform: 'rotate(2deg)' },
          '75%': { transform: 'rotate(-2deg)' },
        },
        wiggle: {
          '0%, 100%': { transform: 'translateX(0)' },
          '25%': { transform: 'translateX(-4px)' },
          '75%': { transform: 'translateX(4px)' },
        },
        fall: {
          from: { top: '-20px', opacity: '1' },
          to: { top: '100%', opacity: '0' },
        },
      },
    },
  },
  plugins: [],
} satisfies Config;
