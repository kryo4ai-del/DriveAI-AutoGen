// Current (Limited routing)
enum RouteDestination: Hashable {
    case home
    case questionCategory(id: String)
    case examStart
    case result(sessionId: String)
    case profile
}

// Improved (Deep link compatible)
enum RouteDestination: Hashable {
    case home
    case questionCategory(id: String)
    case questionDetail(id: String) // Specific question (for retry/review)
    case examStart(simulationMode: Bool = true)
    case result(sessionId: String, animated: Bool = true)
    case profile
    case settings
    
    // Support URL deep linking (for App Store "Learn More" links, etc.)
    init?(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        switch components.host {
        case "exam.driveai.app":
            self = .examStart()
        case "question.driveai.app":
            if let id = components.queryItems?.first(where: { $0.name == "id" })?.value {
                self = .questionDetail(id: id)
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}

// Usage in App
@main