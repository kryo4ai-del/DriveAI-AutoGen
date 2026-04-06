import Foundation

/// Premium features available in DriveAI.
enum PremiumFeature: String, CaseIterable {
    case unlimitedAttempts
    case examSimulation
    case detailedStats
    case noAds
    case offlineMode
    case customLearningPath
    case prioritySupport
    
    /// The subscription tier required for this feature.
    var requiredTier: FeatureTier {
        switch self {
        case .unlimitedAttempts, .examSimulation, .detailedStats, .noAds, .offlineMode, .customLearningPath, .prioritySupport:
            return .premium
        }
    }
    
    var displayName: String {
        switch self {
        case .unlimitedAttempts:
            return NSLocalizedString("unlimited_attempts", comment: "Unlimited attempts")
        case .examSimulation:
            return NSLocalizedString("exam_simulation", comment: "Exam simulation")
        case .detailedStats:
            return NSLocalizedString("detailed_stats", comment: "Detailed statistics")
        case .noAds:
            return NSLocalizedString("no_ads", comment: "No advertisements")
        case .offlineMode:
            return NSLocalizedString("offline_mode", comment: "Offline mode")
        case .customLearningPath:
            return NSLocalizedString("custom_learning_path", comment: "Custom learning path")
        case .prioritySupport:
            return NSLocalizedString("priority_support", comment: "Priority support")
        }
    }
    
    var description: String {
        switch self {
        case .unlimitedAttempts:
            return NSLocalizedString("unlimited_attempts_desc", comment: "Answer questions as many times as you want")
        case .examSimulation:
            return NSLocalizedString("exam_simulation_desc", comment: "Full 30-question exam simulation")
        case .detailedStats:
            return NSLocalizedString("detailed_stats_desc", comment: "Deep analysis of your progress")
        case .noAds:
            return NSLocalizedString("no_ads_desc", comment: "Ad-free learning experience")
        case .offlineMode:
            return NSLocalizedString("offline_mode_desc", comment: "Learn anywhere without internet")
        case .customLearningPath:
            return NSLocalizedString("custom_learning_path_desc", comment: "Intelligent learning routes")
        case .prioritySupport:
            return NSLocalizedString("priority_support_desc", comment: "Fast help from support team")
        }
    }
}

enum FeatureTier {
    case free
    case premium
}