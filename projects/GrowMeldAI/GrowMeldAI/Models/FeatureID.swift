// FeatureID.swift
import Foundation

/// Identifiers for features that can be gated by trial status
enum FeatureID: String, Codable, CaseIterable, Hashable {
    case fullQuestionBank
    case examSimulation
    case detailedStatistics
    case adFreeExperience
    case advancedStudyPlans
}