// File: DriveAI/Models/PurchaseFeature.swift
import Foundation

/// Represents a purchasable feature in DriveAI
/// Includes pricing, localization, and domain-specific benefits
struct PurchaseFeature: Identifiable, Codable, Equatable {
    let id: String
    let productID: String
    let displayName: String
    let localizedDescription: String
    let price: Decimal
    let localizedPrice: String
    let iconName: String
    let category: FeatureCategory
    let benefits: [FeatureBenefit]
    let isSubscription: Bool
    let subscriptionPeriodEnd: Date?
    let requiresInternet: Bool

    var isCurrentlyAvailable: Bool {
        !requiresInternet || NetworkMonitor.shared.isConnected
    }
}

enum FeatureCategory: String, Codable, CaseIterable {
    case examTools = "Prüfungswerkzeuge"
    case learningAids = "Lernhilfen"
    case analytics = "Analysen & Statistiken"
    case contentPacks = "Inhaltspakete"
}

struct FeatureBenefit: Codable, Equatable {
    let description: String
    let improvesExamReadiness: Bool
    let typicalExamQuestionsCovered: Int
}