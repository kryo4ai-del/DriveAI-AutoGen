# DAI Analytics — Web Integration Guide

Firebase Analytics integration for DriveAI web apps.
Cross-platform consistent with iOS and Android.

## 1. Install Dependencies

```bash
npm install firebase
```

## 2. Firebase Config

Create your config from the Firebase Console (Project Settings > General > Your apps > Web app):

```typescript
// src/firebaseConfig.ts
export const firebaseConfig = {
  apiKey: "your-api-key",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef",
  measurementId: "G-XXXXXXXXXX"
};
```

Or copy `firebaseConfig.template.ts` and replace the placeholders.

## 3. Initialize Analytics

Call `initAnalytics()` once in your app entry point:

```typescript
// src/main.ts
import { initAnalytics } from "./analytics/analyticsManager";
import { firebaseConfig } from "./firebaseConfig";

initAnalytics(firebaseConfig);
```

## 4. Log Events

### Direct logging

```typescript
import { logEvent, logScreenView, logFeatureUsed } from "./analytics/analyticsManager";

// Screen view
logScreenView("Dashboard");

// Feature usage
logFeatureUsed("dark_mode_toggle");

// Custom event
logEvent("button_clicked", { button_id: "cta_signup" });
```

### Using typed event factories

```typescript
import { logEvent } from "./analytics/analyticsManager";
import { daiPurchaseComplete, daiErrorOccurred } from "./analytics/analyticsEvents";

// Type-safe event creation
const event = daiPurchaseComplete("pro_plan", 9.99, "USD", "txn_123");
logEvent(event.name, event.parameters);

// Error tracking
const error = daiErrorOccurred("API_TIMEOUT", "Request to /api/data timed out", false);
logEvent(error.name, error.parameters);
```

## 5. React Hook Example

Use this hook to automatically track screen views on route changes:

```typescript
// src/hooks/useAnalytics.ts
import { useEffect } from "react";
import { useLocation } from "react-router-dom";
import { logScreenView } from "../analytics/analyticsManager";

/**
 * Automatically logs a screen_view event whenever the route changes.
 * Place this once in your App component or layout wrapper.
 */
export function useAnalytics(): void {
  const location = useLocation();

  useEffect(() => {
    // Derive screen name from pathname: "/dashboard/settings" -> "dashboard_settings"
    const screenName = location.pathname
      .replace(/^\//, "")
      .replace(/\//g, "_") || "home";

    logScreenView(screenName);
  }, [location.pathname]);
}
```

Usage in your App component:

```tsx
// src/App.tsx
import { BrowserRouter } from "react-router-dom";
import { useAnalytics } from "./hooks/useAnalytics";

function AppContent() {
  useAnalytics();

  return (
    <Routes>
      {/* your routes */}
    </Routes>
  );
}

export default function App() {
  return (
    <BrowserRouter>
      <AppContent />
    </BrowserRouter>
  );
}
```

## 6. Lifecycle Tracking (Optional)

Track app open and background events for session analysis:

```typescript
import { logEvent } from "./analytics/analyticsManager";
import { daiAppOpen, daiAppBackground } from "./analytics/analyticsEvents";

// On app load
const openEvent = daiAppOpen();
logEvent(openEvent.name, openEvent.parameters);

// On visibility change
document.addEventListener("visibilitychange", () => {
  if (document.visibilityState === "hidden") {
    const bgEvent = daiAppBackground();
    logEvent(bgEvent.name, bgEvent.parameters);
  }
});
```

## Notes

- **No Crashlytics for Web** — Firebase Crashlytics is not available for web apps. Use `daiErrorOccurred()` events for error tracking instead.
- **SSR Safety** — `initAnalytics()` checks `isSupported()` before initializing. Safe to call in SSR environments (it will simply skip initialization).
- **Event Prefix** — All custom events are automatically prefixed with `dai_`. Do not add the prefix manually when using `logEvent()`.
- **Cross-Platform** — Event names are identical to iOS (`AnalyticsManager.swift`) and Android (`AnalyticsManager.kt`).
