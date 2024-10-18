module.exports = {
    setupFilesAfterEnv: ['./jest.setup.js'],
    testEnvironment: 'jsdom', // Ensures Jest uses jsdom for browser-like environment
    transform: {
      '^.+\\.jsx?$': 'babel-jest', // Ensures Babel is used to transform JSX/ES6
    },
    moduleFileExtensions: ['js', 'jsx'],
    transformIgnorePatterns: ['frontend/node_modules/'],
    


  };
  