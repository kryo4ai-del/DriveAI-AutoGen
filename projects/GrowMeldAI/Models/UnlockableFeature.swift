import Foundation

enum UnlockableFeature: String, Codable, Hashable, CaseIterable {
    case unlimitedExams = "feature.unlimited_exams"
    case advancedAnalytics = "feature.advanced_analytics"
    case customStudyPlans = "feature.custom_study_plans"
    case offlineSync = "feature.offline_sync"
    
    var displayName: String {
        switch self {
        case .unlimitedExams:
            return "Unbegrenzte Prüfungen"
        case .advancedAnalytics:
            return "Detaillierte Statistiken"
        case .customStudyPlans:
            return "Personalisierte Lernpläne"
        case .offlineSync:
            return "Offline-Synchronisierung"
        }
    }
    
    var description: String {
        switch self {
        case .unlimitedExams:
            return "Üben Sie unbegrenzte Prüfungen ohne tägliche Limits."
        case .advancedAnalytics:
            return "Erweiterte Fehleranalyse und Lerntrends für gezieltes Training."
        case .customStudyPlans:
            return "KI-gestützte, personalisierte Lernpläne basierend auf deinen Schwächen."
        case .offlineSync:
            return "Lerne überall – Deine Fortschritte synchronisieren sich automatisch."
        }
    }
    
    var appStoreProductId: String {
        switch self {
        case .unlimitedExams:
            return "com.driveai.purchase.unlimited_exams"
        case .advancedAnalytics:
            return "com.driveai.purchase.advanced_analytics"
        case .customStudyPlans:
            return "com.driveai.purchase.custom_study_plans"
        case .offlineSync:
            return "com.driveai.purchase.offline_sync"
        }
    }
    
    var icon: String {
        switch self {
        case .unlimitedExams:
            return "repeat.circle.fill"
        case .advancedAnalytics:
            return "chart.bar.xaxis"
        case .customStudyPlans:
            return "list.bullet.rectangle.fill"
        case .offlineSync:
            return "icloud.and.arrow.up.fill"
        }
    }
}