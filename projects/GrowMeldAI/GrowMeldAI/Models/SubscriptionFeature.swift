import Foundation

/// Feature flags tied to subscription tier
public enum SubscriptionFeature: String, Codable, CaseIterable {
    case unlimitedExams
    case adFree
    case offlineMode
    case personalizedTracking
    case examSimulation30
    case categoryFilter
    case detailedAnalytics
    
    // MARK: - Metadata
    
    public var displayName: String {
        switch self {
        case .unlimitedExams:
            return "Unbegrenzte Prüfungen"
        case .adFree:
            return "Werbefrei"
        case .offlineMode:
            return "Offline-Modus"
        case .personalizedTracking:
            return "Personalisiertes Tracking"
        case .examSimulation30:
            return "30-Fragen-Prüfung"
        case .categoryFilter:
            return "Kategorie-Filter"
        case .detailedAnalytics:
            return "Detaillierte Analyse"
        }
    }
    
    public var description: String {
        switch self {
        case .unlimitedExams:
            return "Übe unbegrenzt Fragen ohne Limits"
        case .adFree:
            return "Lerne konzentriert ohne Ablenkung"
        case .offlineMode:
            return "Zugang zu Inhalten überall, auch ohne Internet"
        case .personalizedTracking:
            return "Sehe deine Fortschritte und schwachen Punkte"
        case .examSimulation30:
            return "Trainiere unter Prüfungsbedingungen"
        case .categoryFilter:
            return "Filtere Fragen nach Kategorie"
        case .detailedAnalytics:
            return "Tiefgehende Leistungsanalysen"
        }
    }
    
    /// Psychological benefit framing for paywall
    public var psychologicalBenefit: String {
        switch self {
        case .unlimitedExams:
            return "Reduziere Prüfungsangst durch Übung"
        case .adFree:
            return "Fokussiere dich auf dein Ziel"
        case .offlineMode:
            return "Lerne überall, jederzeit"
        case .personalizedTracking:
            return "Baue Selbstvertrauen auf"
        case .examSimulation30:
            return "Trainiere unter Druck"
        case .categoryFilter:
            return "Zielgerichtetes Lernen"
        case .detailedAnalytics:
            return "Verstehe deine Stärken und Schwächen"
        }
    }
    
    // MARK: - Tier Availability
    
    public static func available(for tier: SubscriptionTier) -> [SubscriptionFeature] {
        switch tier {
        case .trial:
            return [.examSimulation30, .categoryFilter]
        case .monthly:
            return [
                .unlimitedExams, .adFree, .offlineMode, .personalizedTracking,
                .examSimulation30, .categoryFilter, .detailedAnalytics
            ]
        case .yearly:
            return SubscriptionFeature.allCases
        }
    }
    
    public static func isAvailable(_ feature: SubscriptionFeature, for tier: SubscriptionTier) -> Bool {
        available(for: tier).contains(feature)
    }
}