// analyticsEvents.ts
// DAI-Core Analytics Event Definitions — Web
//
// Type-safe event factory functions for all standard DAI events.
// Event names are cross-platform identical with iOS/Android.
// All events use the "dai_" prefix.

// ── Types ────────────────────────────────────────────────────────

/** A structured analytics event ready to be logged. */
export interface AnalyticsEvent {
  name: string;
  parameters?: Record<string, any>;
}

// ── Lifecycle Events ─────────────────────────────────────────────

/** App opened / page loaded. */
export function daiAppOpen(): AnalyticsEvent {
  return { name: "dai_app_open" };
}

/** App moved to background (visibilitychange / pagehide). */
export function daiAppBackground(): AnalyticsEvent {
  return { name: "dai_app_background" };
}

// ── Onboarding Events ────────────────────────────────────────────

/** User started the onboarding flow. */
export function daiOnboardingStart(): AnalyticsEvent {
  return { name: "dai_onboarding_start" };
}

/** User reached a specific onboarding step. */
export function daiOnboardingStep(
  step: number,
  stepName: string
): AnalyticsEvent {
  return {
    name: "dai_onboarding_step",
    parameters: {
      step_number: step,
      step_name: stepName,
    },
  };
}

/** User completed the entire onboarding flow. */
export function daiOnboardingComplete(): AnalyticsEvent {
  return { name: "dai_onboarding_complete" };
}

/** User skipped the onboarding flow. */
export function daiOnboardingSkip(atStep?: number): AnalyticsEvent {
  return {
    name: "dai_onboarding_skip",
    parameters: atStep !== undefined ? { skipped_at_step: atStep } : undefined,
  };
}

// ── Feature Events ───────────────────────────────────────────────

/** User actively used a feature. */
export function daiFeatureUsed(featureName: string): AnalyticsEvent {
  return {
    name: "dai_feature_used",
    parameters: { feature_name: featureName },
  };
}

/** User discovered a feature (first interaction / tooltip shown). */
export function daiFeatureDiscovered(featureName: string): AnalyticsEvent {
  return {
    name: "dai_feature_discovered",
    parameters: { feature_name: featureName },
  };
}

// ── Session Events ───────────────────────────────────────────────

/** Session heartbeat — user is actively using the app. */
export function daiSessionActive(
  durationSeconds: number
): AnalyticsEvent {
  return {
    name: "dai_session_active",
    parameters: { duration_seconds: durationSeconds },
  };
}

// ── Content Events ───────────────────────────────────────────────

/** User viewed a piece of content. */
export function daiContentViewed(
  contentType: string,
  contentId: string
): AnalyticsEvent {
  return {
    name: "dai_content_viewed",
    parameters: {
      content_type: contentType,
      content_id: contentId,
    },
  };
}

// ── Monetization Events ──────────────────────────────────────────

/** User started a purchase flow. */
export function daiPurchaseStart(
  itemId: string,
  value?: number,
  currency?: string
): AnalyticsEvent {
  const parameters: Record<string, any> = { item_id: itemId };
  if (value !== undefined) parameters.value = value;
  if (currency !== undefined) parameters.currency = currency;
  return {
    name: "dai_purchase_start",
    parameters,
  };
}

/** User completed a purchase. */
export function daiPurchaseComplete(
  itemId: string,
  value: number,
  currency: string,
  transactionId?: string
): AnalyticsEvent {
  const parameters: Record<string, any> = {
    item_id: itemId,
    value,
    currency,
  };
  if (transactionId !== undefined) parameters.transaction_id = transactionId;
  return {
    name: "dai_purchase_complete",
    parameters,
  };
}

/** User started a subscription. */
export function daiSubscriptionStart(
  planId: string,
  value?: number,
  currency?: string
): AnalyticsEvent {
  const parameters: Record<string, any> = { plan_id: planId };
  if (value !== undefined) parameters.value = value;
  if (currency !== undefined) parameters.currency = currency;
  return {
    name: "dai_subscription_start",
    parameters,
  };
}

/** Ad impression recorded. */
export function daiAdImpression(
  adUnit: string,
  adFormat?: string
): AnalyticsEvent {
  const parameters: Record<string, any> = { ad_unit: adUnit };
  if (adFormat !== undefined) parameters.ad_format = adFormat;
  return {
    name: "dai_ad_impression",
    parameters,
  };
}

// ── Error Events ─────────────────────────────────────────────────

/** An error occurred in the app. */
export function daiErrorOccurred(
  errorCode: string,
  errorMessage: string,
  isFatal?: boolean
): AnalyticsEvent {
  return {
    name: "dai_error_occurred",
    parameters: {
      error_code: errorCode,
      error_message: errorMessage,
      is_fatal: isFatal ?? false,
    },
  };
}
