// MARK: - Models/TrialFeature.swift
import Foundation

/// Represents a trial-gated feature.
enum TrialFeature: String, CaseIterable, Codable {
    case examSimulation
    case detailedStats
    case allCategories
    case offlineMode
    case customLearningPath

    var displayName: String {
        switch self {
        case .examSimulation:
            return NSLocalizedString("trial_feature_exam_simulation", comment: "Exam Simulation")
        case .detailedStats:
            return NSLocalizedString("trial_feature_detailed_stats", comment: "Detailed Statistics")
        case .allCategories:
            return NSLocalizedString("trial_feature_all_categories", comment: "All Categories")
        case .offlineMode:
            return NSLocalizedString("trial_feature_offline_mode", comment: "Offline Mode")
        case .customLearningPath:
            return NSLocalizedString("trial_feature_custom_path", comment: "Custom Learning Path")
        }
    }
}