import Foundation

/// Centralized subscription module localization keys.
/// Reduces typos and makes translations easier to maintain.
enum SubscriptionLocalizations {
    enum Trial {
        static let expiringAnnouncement = "subscription.trial.expiring_announcement"
        static let expiringLabel = "subscription.trial.label"
        static let upgradeButton = "subscription.trial.upgrade_button"
        static let featureLossWarning = "subscription.trial.feature_loss_warning"
    }
    
    enum Paywall {
        static let title = "subscription.paywall.title"
        static let planSelectionHint = "subscription.paywall.plan_selection_hint"
        static let closeButton = "subscription.paywall.close_button"
        static let closeHint = "subscription.paywall.close_hint"
        static let subscribeButton = "subscription.paywall.subscribe_button"
        static let legalDisclaimer = "subscription.paywall.legal_disclaimer"
        static let processingLabel = "subscription.paywall.processing_label"
    }
    
    enum PricingCard {
        static let bestValueBadge = "subscription.pricing.best_value_badge"
        static let bestValueHint = "subscription.pricing.best_value_hint"
        static let pricePerMonth = "subscription.pricing.price_per_month"
        static let selectedHint = "subscription.pricing.selected_hint"
        static let unselectedHint = "subscription.pricing.unselected_hint"
    }
    
    enum Errors {
        static let networkUnavailable = "subscription.error.network_unavailable"
        static let networkUnavailableHint = "subscription.error.network_unavailable_hint"
        static let invalidPlan = "subscription.error.invalid_plan"
        static let transactionFailed = "subscription.error.transaction_failed"
        static let transactionFailedHint = "subscription.error.transaction_failed_hint"
        static let userCancelled = "subscription.error.user_cancelled"
        static let unknown = "subscription.error.unknown"
    }
}