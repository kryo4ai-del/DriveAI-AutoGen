// AnalyticsEvents.cs
// DAI-Core Standard Analytics Events for Unity
//
// Static class with all standard events every DAI-Core Unity app should track.
// Event names are identical to iOS/Android/Web: prefixed with "dai_".
//
// Usage:
//   var (name, parameters) = AnalyticsEvents.AppOpen();
//   AnalyticsManager.Instance.Log(name, parameters);
//
//   var (name, parameters) = AnalyticsEvents.FeatureUsed("dark_mode");
//   AnalyticsManager.Instance.Log(name, parameters);

using System.Collections.Generic;

namespace DriveAI.Analytics
{
    /// <summary>
    /// Standard analytics events for DAI-Core Unity apps.
    /// Static methods return (eventName, parameters) tuples for use with AnalyticsManager.Log().
    /// All event names are pre-prefixed with "dai_" — cross-platform identical.
    /// </summary>
    public static class AnalyticsEvents
    {
        private const string Prefix = "dai_";

        // ── Session Events ───────────────────────────────────────────

        /// <summary>App opened / foregrounded.</summary>
        public static (string name, Dictionary<string, object> parameters) AppOpen()
        {
            return ($"{Prefix}app_open", null);
        }

        /// <summary>App sent to background.</summary>
        public static (string name, Dictionary<string, object> parameters) AppBackground()
        {
            return ($"{Prefix}app_background", null);
        }

        // ── Onboarding Funnel ────────────────────────────────────────

        /// <summary>User started the onboarding flow.</summary>
        public static (string name, Dictionary<string, object> parameters) OnboardingStart()
        {
            return ($"{Prefix}onboarding_start", null);
        }

        /// <summary>User completed a specific onboarding step.</summary>
        public static (string name, Dictionary<string, object> parameters) OnboardingStep(int step, string stepName)
        {
            return ($"{Prefix}onboarding_step", new Dictionary<string, object>
            {
                { "step", step },
                { "step_name", stepName }
            });
        }

        /// <summary>User completed the full onboarding.</summary>
        public static (string name, Dictionary<string, object> parameters) OnboardingComplete()
        {
            return ($"{Prefix}onboarding_complete", null);
        }

        /// <summary>User skipped onboarding.</summary>
        public static (string name, Dictionary<string, object> parameters) OnboardingSkip()
        {
            return ($"{Prefix}onboarding_skip", null);
        }

        // ── Feature Usage ────────────────────────────────────────────

        /// <summary>User actively used a feature.</summary>
        public static (string name, Dictionary<string, object> parameters) FeatureUsed(string featureName)
        {
            return ($"{Prefix}feature_used", new Dictionary<string, object>
            {
                { "feature_name", featureName }
            });
        }

        /// <summary>User discovered / saw a feature for the first time.</summary>
        public static (string name, Dictionary<string, object> parameters) FeatureDiscovered(string featureName)
        {
            return ($"{Prefix}feature_discovered", new Dictionary<string, object>
            {
                { "feature_name", featureName }
            });
        }

        // ── Engagement ───────────────────────────────────────────────

        /// <summary>Active session duration heartbeat.</summary>
        public static (string name, Dictionary<string, object> parameters) SessionActive(int durationSeconds)
        {
            return ($"{Prefix}session_active", new Dictionary<string, object>
            {
                { "duration_seconds", durationSeconds }
            });
        }

        /// <summary>User viewed a piece of content.</summary>
        public static (string name, Dictionary<string, object> parameters) ContentViewed(string contentId, string contentType)
        {
            return ($"{Prefix}content_viewed", new Dictionary<string, object>
            {
                { "content_id", contentId },
                { "content_type", contentType }
            });
        }

        // ── Monetization ─────────────────────────────────────────────

        /// <summary>User initiated a purchase flow.</summary>
        public static (string name, Dictionary<string, object> parameters) PurchaseStart(string productId)
        {
            return ($"{Prefix}purchase_start", new Dictionary<string, object>
            {
                { "product_id", productId }
            });
        }

        /// <summary>Purchase completed successfully.</summary>
        public static (string name, Dictionary<string, object> parameters) PurchaseComplete(string productId, double value, string currency)
        {
            return ($"{Prefix}purchase_complete", new Dictionary<string, object>
            {
                { "product_id", productId },
                { "value", value },
                { "currency", currency }
            });
        }

        /// <summary>User started a subscription.</summary>
        public static (string name, Dictionary<string, object> parameters) SubscriptionStart(string planId)
        {
            return ($"{Prefix}subscription_start", new Dictionary<string, object>
            {
                { "plan_id", planId }
            });
        }

        /// <summary>An ad was shown to the user.</summary>
        public static (string name, Dictionary<string, object> parameters) AdImpression(string adType)
        {
            return ($"{Prefix}ad_impression", new Dictionary<string, object>
            {
                { "ad_type", adType }
            });
        }

        // ── Errors ───────────────────────────────────────────────────

        /// <summary>A non-fatal error occurred.</summary>
        public static (string name, Dictionary<string, object> parameters) ErrorOccurred(string domain, int code, string description)
        {
            return ($"{Prefix}error_occurred", new Dictionary<string, object>
            {
                { "error_domain", domain },
                { "error_code", code },
                { "error_description", description }
            });
        }
    }
}
