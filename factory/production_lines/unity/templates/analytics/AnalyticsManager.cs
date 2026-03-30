// AnalyticsManager.cs
// DAI-Core Firebase Analytics Manager for Unity
//
// Central analytics singleton (MonoBehaviour) for all DriveAI Unity apps.
// Generic template — no app-specific logic.
//
// Usage:
//   AnalyticsManager.Instance.Configure();
//   AnalyticsManager.Instance.LogEvent("custom_action", new Dictionary<string, object> { { "key", "value" } });
//   AnalyticsManager.Instance.LogScreenView("HomeScreen");

using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using UnityEngine;
using Firebase;
using Firebase.Analytics;

namespace DriveAI.Analytics
{
    /// <summary>
    /// Central Analytics Manager for DAI-Core Unity apps.
    /// MonoBehaviour-based singleton — persists across scene loads.
    /// All methods are fire-and-forget after Configure() completes.
    /// </summary>
    public class AnalyticsManager : MonoBehaviour
    {
        // ── Singleton ────────────────────────────────────────────────

        private static AnalyticsManager _instance;

        /// <summary>
        /// Singleton instance. Accessible from any script after the first scene loads.
        /// </summary>
        public static AnalyticsManager Instance
        {
            get
            {
                if (_instance == null)
                {
                    Debug.LogError("[DAI Analytics] AnalyticsManager not found. " +
                        "Add it to an empty GameObject in your first scene.");
                }
                return _instance;
            }
        }

        // ── State ────────────────────────────────────────────────────

        private const string EventPrefix = "dai_";

        /// <summary>Whether Configure() has completed successfully.</summary>
        public bool IsConfigured { get; private set; }

        private bool _isConfiguring;

        // ── Unity Lifecycle ──────────────────────────────────────────

        private void Awake()
        {
            if (_instance != null && _instance != this)
            {
                Debug.LogWarning("[DAI Analytics] Duplicate AnalyticsManager destroyed.");
                Destroy(gameObject);
                return;
            }

            _instance = this;
            DontDestroyOnLoad(gameObject);
        }

        private void OnDestroy()
        {
            if (_instance == this)
            {
                _instance = null;
            }
        }

        // ── Configuration ────────────────────────────────────────────

        /// <summary>
        /// Initialize Firebase. Call once from your startup script.
        /// Firebase Unity SDK requires async dependency resolution before any API call.
        /// </summary>
        /// <returns>True if initialization succeeded, false otherwise.</returns>
        public async Task<bool> Configure()
        {
            if (IsConfigured) return true;
            if (_isConfiguring) return false;

            _isConfiguring = true;

            try
            {
                var dependencyStatus = await FirebaseApp.CheckAndFixDependenciesAsync();

                if (dependencyStatus == DependencyStatus.Available)
                {
                    // Firebase is ready
                    FirebaseAnalytics.SetAnalyticsCollectionEnabled(true);
                    IsConfigured = true;
                    Debug.Log("[DAI Analytics] Firebase initialized successfully.");
                    return true;
                }
                else
                {
                    Debug.LogError($"[DAI Analytics] Firebase dependency error: {dependencyStatus}");
                    return false;
                }
            }
            catch (Exception ex)
            {
                Debug.LogError($"[DAI Analytics] Firebase init failed: {ex.Message}");
                return false;
            }
            finally
            {
                _isConfiguring = false;
            }
        }

        // ── Core Logging ─────────────────────────────────────────────

        /// <summary>
        /// Log a custom event with optional parameters.
        /// The event name is automatically prefixed with "dai_" if not already.
        /// </summary>
        public void LogEvent(string name, Dictionary<string, object> parameters = null)
        {
            if (!EnsureConfigured()) return;

            string prefixedName = EnsurePrefix(name);

            if (parameters == null || parameters.Count == 0)
            {
                FirebaseAnalytics.LogEvent(prefixedName);
                return;
            }

            var firebaseParams = new List<Parameter>();

            foreach (var kvp in parameters)
            {
                if (kvp.Value is string strVal)
                    firebaseParams.Add(new Parameter(kvp.Key, strVal));
                else if (kvp.Value is int intVal)
                    firebaseParams.Add(new Parameter(kvp.Key, intVal));
                else if (kvp.Value is long longVal)
                    firebaseParams.Add(new Parameter(kvp.Key, longVal));
                else if (kvp.Value is double doubleVal)
                    firebaseParams.Add(new Parameter(kvp.Key, doubleVal));
                else if (kvp.Value is float floatVal)
                    firebaseParams.Add(new Parameter(kvp.Key, (double)floatVal));
                else
                    firebaseParams.Add(new Parameter(kvp.Key, kvp.Value?.ToString() ?? ""));
            }

            FirebaseAnalytics.LogEvent(prefixedName, firebaseParams.ToArray());
        }

        /// <summary>
        /// Log a screen view event.
        /// Maps to Firebase screen_view with screen_name parameter.
        /// </summary>
        public void LogScreenView(string screenName)
        {
            if (!EnsureConfigured()) return;

            FirebaseAnalytics.LogEvent(
                FirebaseAnalytics.EventScreenView,
                new Parameter(FirebaseAnalytics.ParameterScreenName, screenName),
                new Parameter(FirebaseAnalytics.ParameterScreenClass, screenName)
            );
        }

        // ── Convenience Methods ──────────────────────────────────────

        /// <summary>
        /// Log feature usage. Cross-platform consistent with iOS/Android.
        /// </summary>
        public void LogFeatureUsed(string featureName)
        {
            LogEvent("feature_used", new Dictionary<string, object>
            {
                { "feature_name", featureName }
            });
        }

        /// <summary>
        /// Log a funnel step for conversion tracking.
        /// Cross-platform consistent with iOS/Android.
        /// </summary>
        public void LogFunnelStep(string funnelName, int step, string stepName)
        {
            LogEvent("funnel_step", new Dictionary<string, object>
            {
                { "funnel_name", funnelName },
                { "step_number", step },
                { "step_name", stepName }
            });
        }

        /// <summary>
        /// Log a conversion event (purchase, subscription, etc.).
        /// Cross-platform consistent with iOS/Android.
        /// </summary>
        public void LogConversion(string type, double? value = null, string currency = null)
        {
            var parameters = new Dictionary<string, object>
            {
                { "conversion_type", type }
            };

            if (value.HasValue)
            {
                parameters["value"] = value.Value;
            }

            if (!string.IsNullOrEmpty(currency))
            {
                parameters["currency"] = currency;
            }

            LogEvent("conversion", parameters);
        }

        // ── User Properties ──────────────────────────────────────────

        /// <summary>
        /// Set a custom user property for audience segmentation.
        /// </summary>
        public void SetUserProperty(string name, string value)
        {
            if (!EnsureConfigured()) return;

            FirebaseAnalytics.SetUserProperty(name, value);
        }

        /// <summary>
        /// Set the app profile category (e.g. "gaming", "education", "utility").
        /// Used for cross-platform segmentation.
        /// </summary>
        public void SetAppProfile(string profile)
        {
            SetUserProperty("dai_app_profile", profile);
        }

        // ── Structured Event Logging ─────────────────────────────────

        /// <summary>
        /// Log a pre-built DAI analytics event from AnalyticsEvents.
        /// </summary>
        public void Log(string eventName, Dictionary<string, object> parameters)
        {
            if (!EnsureConfigured()) return;

            // eventName is already prefixed from AnalyticsEvents
            if (parameters == null || parameters.Count == 0)
            {
                FirebaseAnalytics.LogEvent(eventName);
                return;
            }

            var firebaseParams = new List<Parameter>();

            foreach (var kvp in parameters)
            {
                if (kvp.Value is string strVal)
                    firebaseParams.Add(new Parameter(kvp.Key, strVal));
                else if (kvp.Value is int intVal)
                    firebaseParams.Add(new Parameter(kvp.Key, intVal));
                else if (kvp.Value is long longVal)
                    firebaseParams.Add(new Parameter(kvp.Key, longVal));
                else if (kvp.Value is double doubleVal)
                    firebaseParams.Add(new Parameter(kvp.Key, doubleVal));
                else if (kvp.Value is float floatVal)
                    firebaseParams.Add(new Parameter(kvp.Key, (double)floatVal));
                else
                    firebaseParams.Add(new Parameter(kvp.Key, kvp.Value?.ToString() ?? ""));
            }

            FirebaseAnalytics.LogEvent(eventName, firebaseParams.ToArray());
        }

        // ── Internal ─────────────────────────────────────────────────

        private bool EnsureConfigured()
        {
            if (!IsConfigured)
            {
                Debug.LogWarning("[DAI Analytics] Not configured. Call Configure() first.");
                return false;
            }
            return true;
        }

        private string EnsurePrefix(string name)
        {
            return name.StartsWith(EventPrefix) ? name : EventPrefix + name;
        }
    }
}
