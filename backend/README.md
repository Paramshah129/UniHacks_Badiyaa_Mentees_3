# BondBox Backend

This folder contains the backend logic for the BondBox application, built using Firebase Cloud Functions.

## Structure

- **functions/**: Contains the Cloud Functions source code.
  - `index.js`: The main entry point for all backend triggers and logic.

## Deployment

To deploy the backend functions:

1.  Make sure you have the Firebase CLI installed: `npm install -g firebase-tools`
2.  Navigate to the `functions` directory: `cd functions`
3.  Install dependencies: `npm install`
4.  Deploy to Firebase: `firebase deploy --only functions`
