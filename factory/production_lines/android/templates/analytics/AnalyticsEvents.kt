package {{PACKAGE_NAME}}.analytics

import android.os.Bundle
import androidx.core.os.bundleOf

/**
 * DriveAI Standard Analytics Events — Sealed Class Hierarchy
 *
 * Event names are IDENTICAL to iOS for cross-platform consistency.
 * All events use the "dai_" prefix.
 *
 * Usage:
 *   val event = AnalyticsEvents.Session.AppOpen
 *   AnalyticsManager.logEvent(event.eventName, event.parameters)
 */
sealed class AnalyticsEvents(
    val eventName: String,
    val parameters: Bundle? = null
) {

    // ── Session Events ──────────────────────────────────────────────

    sealed class Session(eventName: String, parameters: Bundle? = null) :
        AnalyticsEvents(eventName, parameters) {

        /** App opened / foregrounded */
        object AppOpen : Session("dai_app_open")

        /** App moved to background */
        object AppBackground : Session("dai_app_background")
    }

    // ── Onboarding Funnel ───────────────────────────────────────────

    sealed class Onboarding(eventName: String, parameters: Bundle? = null) :
        AnalyticsEvents(eventName, parameters) {

        /** User starts onboarding flow */
        object Start : Onboarding("dai_onboarding_start")

        /** User completes a specific onboarding step */
        data class Step(val step: Int, val stepName: String) : Onboarding(
            eventName = "dai_onboarding_step",
            parameters = bundleOf(
                "step_number" to step,
                "step_name" to stepName
            )
        )

        /** User completes entire onboarding */
        object Complete : Onboarding("dai_onboarding_complete")

        /** User skips onboarding */
        data class Skip(val atStep: Int) : Onboarding(
            eventName = "dai_onboarding_skip",
            parameters = bundleOf("skipped_at_step" to atStep)
        )
    }

    // ── Feature Usage ───────────────────────────────────────────────

    sealed class Feature(eventName: String, parameters: Bundle? = null) :
        AnalyticsEvents(eventName, parameters) {

        /** User actively uses a feature */
        data class Used(val featureName: String) : Feature(
            eventName = "dai_feature_used",
            parameters = bundleOf("feature_name" to featureName)
        )

        /** User discovers a feature (first interaction) */
        data class Discovered(val featureName: String) : Feature(
            eventName = "dai_feature_discovered",
            parameters = bundleOf("feature_name" to featureName)
        )
    }

    // ── Engagement ──────────────────────────────────────────────────

    sealed class Engagement(eventName: String, parameters: Bundle? = null) :
        AnalyticsEvents(eventName, parameters) {

        /** Active session milestone (e.g. 1min, 5min, 10min) */
        data class SessionActive(val durationSeconds: Long) : Engagement(
            eventName = "dai_session_active",
            parameters = bundleOf("duration_seconds" to durationSeconds)
        )

        /** User views specific content */
        data class ContentViewed(val contentType: String, val contentId: String) : Engagement(
            eventName = "dai_content_viewed",
            parameters = bundleOf(
                "content_type" to contentType,
                "content_id" to contentId
            )
        )
    }

    // ── Monetization ────────────────────────────────────────────────

    sealed class Monetization(eventName: String, parameters: Bundle? = null) :
        AnalyticsEvents(eventName, parameters) {

        /** User initiates a purchase */
        data class PurchaseStart(val productId: String, val value: Double? = null) : Monetization(
            eventName = "dai_purchase_start",
            parameters = bundleOf(
                "product_id" to productId
            ).apply {
                value?.let { putDouble("value", it) }
            }
        )

        /** Purchase completed successfully */
        data class PurchaseComplete(
            val productId: String,
            val value: Double,
            val currency: String
        ) : Monetization(
            eventName = "dai_purchase_complete",
            parameters = bundleOf(
                "product_id" to productId,
                "value" to value,
                "currency" to currency
            )
        )

        /** Subscription started */
        data class SubscriptionStart(
            val planId: String,
            val value: Double,
            val currency: String
        ) : Monetization(
            eventName = "dai_subscription_start",
            parameters = bundleOf(
                "plan_id" to planId,
                "value" to value,
                "currency" to currency
            )
        )

        /** Ad impression tracked */
        data class AdImpression(
            val adUnit: String,
            val adFormat: String? = null
        ) : Monetization(
            eventName = "dai_ad_impression",
            parameters = bundleOf(
                "ad_unit" to adUnit
            ).apply {
                adFormat?.let { putString("ad_format", it) }
            }
        )
    }

    // ── Errors ──────────────────────────────────────────────────────

    sealed class Error(eventName: String, parameters: Bundle? = null) :
        AnalyticsEvents(eventName, parameters) {

        /** Non-fatal error occurred */
        data class Occurred(
            val errorCode: String,
            val errorMessage: String,
            val screen: String? = null
        ) : Error(
            eventName = "dai_error_occurred",
            parameters = bundleOf(
                "error_code" to errorCode,
                "error_message" to errorMessage
            ).apply {
                screen?.let { putString("screen", it) }
            }
        )
    }
}
