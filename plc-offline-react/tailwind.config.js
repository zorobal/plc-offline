/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: '#2d80d2',
        secondary: '#1a5f9e',
        accent: '#4a9eff',
        dark: '#1e293b',
        light: '#f8fafc',
      },
    },
  },
  plugins: [],
}
