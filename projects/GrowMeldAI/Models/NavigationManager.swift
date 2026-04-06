@Observable
class NavigationManager {
    var navigationPath: NavigationPath = NavigationPath()
    
    func push(_ route: AppRoute) {
        navigationPath.append(route)
        
        // ✅ Announce navigation change
        let announcement = accessibilityLabel(for: route)
        UIAccessibility.post(
            notification: .screenChanged,
            argument: announcement
        )
    }
    
    private func accessibilityLabel(for route: AppRoute) -> String {
        switch route {
        case .home:
            return "Startseite wird geöffnet"
        case .categoryDetail(let category):
            return "\(category.displayName) Fragen werden geöffnet"
        case .question:
            return "Neue Frage wird geöffnet"
        case .examSimulation:
            return "Prüfungssimulation wird gestartet"
        case .examResult:
            return "Prüfungsergebnisse werden angezeigt"
        case .profile:
            return "Profilseite wird geöffnet"
        }
    }
}