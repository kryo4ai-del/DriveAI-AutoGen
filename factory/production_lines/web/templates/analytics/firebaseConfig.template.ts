// firebaseConfig.template.ts
// DAI-Core Firebase Configuration Template — Web
//
// Copy this file to your project as firebaseConfig.ts
// and replace all {{PLACEHOLDER}} values with your actual Firebase config.
// Find these values in Firebase Console > Project Settings > General > Your apps.

import { FirebaseConfig } from "./analyticsManager";

export const firebaseConfig: FirebaseConfig = {
  apiKey: "{{FIREBASE_API_KEY}}",
  authDomain: "{{FIREBASE_AUTH_DOMAIN}}",
  projectId: "{{FIREBASE_PROJECT_ID}}",
  storageBucket: "{{FIREBASE_STORAGE_BUCKET}}",
  messagingSenderId: "{{FIREBASE_MESSAGING_SENDER_ID}}",
  appId: "{{FIREBASE_APP_ID}}",
  measurementId: "{{FIREBASE_MEASUREMENT_ID}}",
};
