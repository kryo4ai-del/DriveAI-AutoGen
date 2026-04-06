// Models/Subscription/SubscriptionTier.swift
import Foundation

enum SubscriptionTier: String, Codable, CaseIterable {
    case free
    case premium
    case premiumPlus = "premium_plus"
    
    var displayName: String {
        switch self {
        case .free: "Kostenlos"
        case .premium: "Premium"
        case .premiumPlus: "Premium+"
        }
    }
    
    var yearlyPrice: Decimal {
        switch self {
        case .free: 0
        case .premium: 99.99
        case .premiumPlus: 149.99
        }
    }
    
    var benefits: [SubscriptionBenefit] {
        switch self {
        case .free:
            return [.basicQuestions]
        case .premium:
            return [.basicQuestions, .unlimitedExams, .adFree]
        case .premiumPlus:
            return [.basicQuestions, .unlimitedExams, .adFree, .offlineMode, .personalizedLearning]
        }
    }
}

enum SubscriptionBenefit: String, Codable, CaseIterable {
    case basicQuestions = "basic_questions"
    case unlimitedExams = "unlimited_exams"
    case adFree = "ad_free"
    case offlineMode = "offline_mode"
    case personalizedLearning = "personalized_learning"
    
    var displayName: String {
        switch self {
        case .basicQuestions: "Grundlegende Fragen"
        case .unlimitedExams: "Unbegrenzte Prüfungen"
        case .adFree: "Keine Werbung"
        case .offlineMode: "Offline-Modus"
        case .personalizedLearning: "Personalisiertes Lernen"
        }
    }
}

// Models/Subscription/SubscriptionStatus.swift

// Models/Subscription/UserSubscriptionState.swift
struct UserSubscriptionState: Codable {
    let currentTier: SubscriptionTier
    let status: SubscriptionStatus
    let expiryDate: Date?
    let trialEndDate: Date?
    let autoRenewEnabled: Bool
    let originalPurchaseDate: Date?
    
    init(
        tier: SubscriptionTier = .free,
        status: SubscriptionStatus = .unknown,
        expiryDate: Date? = nil,
        trialEndDate: Date? = nil,
        autoRenewEnabled: Bool = false,
        originalPurchaseDate: Date? = nil
    ) {
        self.currentTier = tier
        self.status = status
        self.expiryDate = expiryDate
        self.trialEndDate = trialEndDate
        self.autoRenewEnabled = autoRenewEnabled
        self.originalPurchaseDate = originalPurchaseDate
    }
    
    var isActive: Bool {
        status == .active || status == .trialActive
    }
    
    var daysUntilExpiry: Int? {
        guard let expiryDate = expiryDate else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day
        return max(0, days ?? 0)
    }
}