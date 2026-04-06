extension PerformanceMetric.MetricType {
    var accessibilityLabel: String {
        switch self {
        case .downloads: return "Downloads gesamt"
        case .rating: return "App-Bewertung"
        case .reviews: return "Anzahl Rezensionen"
        case .activeUsers: return "Aktive Benutzer"
        case .retention: return "Retentionsrate"
        }
    }
}