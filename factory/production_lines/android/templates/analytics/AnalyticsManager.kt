package {{PACKAGE_NAME}}.analytics

import android.content.Context
import android.os.Bundle
import com.google.firebase.analytics.FirebaseAnalytics
import com.google.firebase.crashlytics.FirebaseCrashlytics

/**
 * DriveAI Analytics Manager — Firebase Analytics Singleton
 *
 * Cross-platform consistent with iOS AnalyticsManager.
 * All events use the "dai_" prefix for DriveAI identification.
 *
 * Usage:
 *   AnalyticsManager.configure(applicationContext)
 *   AnalyticsManager.logEvent("custom_action", bundleOf("key" to "value"))
 *   AnalyticsManager.logScreenView("HomeScreen")
 */
object AnalyticsManager {

    private lateinit var firebaseAnalytics: FirebaseAnalytics
    private lateinit var crashlytics: FirebaseCrashlytics
    private var isConfigured = false

    private const val EVENT_PREFIX = "dai_"

    // ── Initialization ──────────────────────────────────────────────

    /**
     * Initialize Firebase Analytics and Crashlytics.
     * Call this in Application.onCreate() before any logging.
     */
    fun configure(context: Context) {
        if (isConfigured) return

        firebaseAnalytics = FirebaseAnalytics.getInstance(context)
        crashlytics = FirebaseCrashlytics.getInstance()
        isConfigured = true
    }

    // ── Core Logging ────────────────────────────────────────────────

    /**
     * Log a custom event with optional parameters.
     * The event name is automatically prefixed with "dai_" if not already.
     */
    fun logEvent(name: String, params: Bundle? = null) {
        ensureConfigured()
        val prefixedName = ensurePrefix(name)
        firebaseAnalytics.logEvent(prefixedName, params)
    }

    /**
     * Log a screen view event.
     * Maps to Firebase screen_view with custom dai_screen_name parameter.
     */
    fun logScreenView(screenName: String) {
        ensureConfigured()
        val params = Bundle().apply {
            putString(FirebaseAnalytics.Param.SCREEN_NAME, screenName)
            putString(FirebaseAnalytics.Param.SCREEN_CLASS, screenName)
        }
        firebaseAnalytics.logEvent(FirebaseAnalytics.Event.SCREEN_VIEW, params)
    }

    // ── Convenience Methods ─────────────────────────────────────────

    /**
     * Log feature usage. Cross-platform consistent with iOS.
     */
    fun logFeatureUsed(featureName: String) {
        logEvent("feature_used", Bundle().apply {
            putString("feature_name", featureName)
        })
    }

    /**
     * Log a funnel step for conversion tracking.
     * Cross-platform consistent with iOS.
     */
    fun logFunnelStep(funnelName: String, step: Int, stepName: String) {
        logEvent("funnel_step", Bundle().apply {
            putString("funnel_name", funnelName)
            putInt("step_number", step)
            putString("step_name", stepName)
        })
    }

    /**
     * Log a conversion event (purchase, subscription, etc.).
     * Cross-platform consistent with iOS.
     */
    fun logConversion(type: String, value: Double? = null, currency: String? = null) {
        logEvent("conversion", Bundle().apply {
            putString("conversion_type", type)
            value?.let { putDouble(FirebaseAnalytics.Param.VALUE, it) }
            currency?.let { putString(FirebaseAnalytics.Param.CURRENCY, it) }
        })
    }

    // ── User Properties ─────────────────────────────────────────────

    /**
     * Set a user property for audience segmentation.
     */
    fun setUserProperty(name: String, value: String) {
        ensureConfigured()
        firebaseAnalytics.setUserProperty(name, value)
    }

    /**
     * Set the app profile category (e.g. "fitness", "finance", "social").
     * Used for cross-platform segmentation.
     */
    fun setAppProfile(profile: String) {
        setUserProperty("dai_app_profile", profile)
    }

    // ── Internal ────────────────────────────────────────────────────

    private fun ensureConfigured() {
        check(isConfigured) {
            "AnalyticsManager not configured. Call configure(context) in Application.onCreate() first."
        }
    }

    private fun ensurePrefix(name: String): String {
        return if (name.startsWith(EVENT_PREFIX)) name else "$EVENT_PREFIX$name"
    }
}
