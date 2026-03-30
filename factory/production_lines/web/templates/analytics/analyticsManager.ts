// analyticsManager.ts
// DAI-Core Firebase Analytics Manager — Web
//
// Central analytics module for all DriveAI web apps.
// Cross-platform consistent with iOS/Android AnalyticsManager.
// Generic template — no app-specific logic.

import { initializeApp, FirebaseOptions } from "firebase/app";
import {
  getAnalytics,
  logEvent as firebaseLogEvent,
  setUserProperties,
  Analytics,
  isSupported,
} from "firebase/analytics";

// ── Types ────────────────────────────────────────────────────────

export interface FirebaseConfig extends FirebaseOptions {
  apiKey: string;
  authDomain: string;
  projectId: string;
  storageBucket: string;
  messagingSenderId: string;
  appId: string;
  measurementId: string;
}

// ── State ────────────────────────────────────────────────────────

const EVENT_PREFIX = "dai_";

let analytics: Analytics | null = null;
let configured = false;

// ── Initialization ───────────────────────────────────────────────

/**
 * Initialize Firebase Analytics.
 * Call once in your app entry point (e.g. main.ts, App.tsx).
 *
 * Does nothing if already configured or if analytics is not supported
 * in the current environment (e.g. SSR / Node).
 */
export async function initAnalytics(
  firebaseConfig: FirebaseConfig
): Promise<void> {
  if (configured) return;

  const supported = await isSupported();
  if (!supported) {
    console.warn("[DAI Analytics] Firebase Analytics not supported in this environment.");
    return;
  }

  const app = initializeApp(firebaseConfig);
  analytics = getAnalytics(app);
  configured = true;
}

// ── Core Logging ─────────────────────────────────────────────────

/**
 * Log a custom event with optional parameters.
 * The event name is automatically prefixed with "dai_" if not already.
 */
export function logEvent(
  name: string,
  parameters?: Record<string, any>
): void {
  if (!analytics) return;
  const prefixedName = ensurePrefix(name);
  firebaseLogEvent(analytics, prefixedName, parameters);
}

/**
 * Log a screen view event.
 * Maps to Firebase screen_view — cross-platform consistent with iOS/Android.
 */
export function logScreenView(screenName: string): void {
  if (!analytics) return;
  firebaseLogEvent(analytics, "screen_view", {
    screen_name: screenName,
  });
}

// ── Convenience Methods ──────────────────────────────────────────

/**
 * Log feature usage. Cross-platform consistent with iOS/Android.
 */
export function logFeatureUsed(featureName: string): void {
  logEvent("feature_used", {
    feature_name: featureName,
  });
}

/**
 * Log a funnel step for conversion tracking.
 * Cross-platform consistent with iOS/Android.
 */
export function logFunnelStep(
  funnelName: string,
  step: number,
  stepName: string
): void {
  logEvent("funnel_step", {
    funnel_name: funnelName,
    step_number: step,
    step_name: stepName,
  });
}

/**
 * Log a conversion event (purchase, subscription, etc.).
 * Cross-platform consistent with iOS/Android.
 */
export function logConversion(
  type: string,
  value?: number,
  currency?: string
): void {
  const params: Record<string, any> = {
    conversion_type: type,
  };
  if (value !== undefined) {
    params.value = value;
  }
  if (currency !== undefined) {
    params.currency = currency;
  }
  logEvent("conversion", params);
}

// ── User Properties ──────────────────────────────────────────────

/**
 * Set a custom user property for audience segmentation.
 */
export function setUserProperty(name: string, value: string): void {
  if (!analytics) return;
  setUserProperties(analytics, { [name]: value });
}

/**
 * Set the app profile category (e.g. "fitness", "finance", "social").
 * Used for cross-platform segmentation.
 */
export function setAppProfile(profile: string): void {
  setUserProperty("dai_app_profile", profile);
}

// ── Internal ─────────────────────────────────────────────────────

function ensurePrefix(name: string): string {
  return name.startsWith(EVENT_PREFIX) ? name : `${EVENT_PREFIX}${name}`;
}
