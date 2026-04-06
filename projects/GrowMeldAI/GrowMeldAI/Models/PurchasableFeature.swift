import Foundation

struct PurchasableFeature: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let category: FeatureCategory
    let price: Decimal
    let currencyCode: String
    let unlockedFeatures: [String]
    let icon: String?
    let isActive: Bool
    
    enum FeatureCategory: String, Codable, CaseIterable {
        case learning
        case analytics
        case export
        case convenience
        
        var displayName: String {
            switch self {
            case .learning: return "Lernen"
            case .analytics: return "Statistiken"
            case .export: return "Export"
            case .convenience: return "Komfort"
            }
        }
    }
    
    static func loadFromBundle() -> [PurchasableFeature] {
        guard let url = Bundle.main.url(forResource: "Features", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([PurchasableFeature].self, from: data) else {
            return Self.fallbackFeatures
        }
        return decoded
    }
    
    private static let fallbackFeatures: [PurchasableFeature] = [
        PurchasableFeature(
            id: "unlimited_exams",
            name: "Unbegrenzte Prüfungssimulationen",
            description: "Führe unbegrenzte vollständige 30-Fragen-Prüfungen durch",
            category: .learning,
            price: 4.99,
            currencyCode: "EUR",
            unlockedFeatures: ["exam_simulation_unlimited"],
            icon: "repeat.circle.fill",
            isActive: true
        ),
        PurchasableFeature(
            id: "performance_analytics",
            name: "Erweiterte Leistungsanalyse",
            description: "Detaillierte Einblicke, Schwachstellen und personalisierte Lernwege",
            category: .analytics,
            price: 3.99,
            currencyCode: "EUR",
            unlockedFeatures: ["analytics_advanced", "insights_personalized"],
            icon: "chart.bar.fill",
            isActive: true
        ),
        PurchasableFeature(
            id: "exam_history_export",
            name: "Prüfungsverlauf exportieren",
            description: "Exportiere deine Ergebnisse als PDF oder CSV",
            category: .export,
            price: 2.99,
            currencyCode: "EUR",
            unlockedFeatures: ["export_pdf", "export_csv"],
            icon: "arrow.up.doc.fill",
            isActive: true
        ),
        PurchasableFeature(
            id: "offline_content",
            name: "Offline-Inhalt",
            description: "Lade alle Fragen für den Offline-Zugang herunter",
            category: .convenience,
            price: 5.99,
            currencyCode: "EUR",
            unlockedFeatures: ["offline_questions", "offline_images"],
            icon: "arrow.down.circle.fill",
            isActive: true
        )
    ]
}
