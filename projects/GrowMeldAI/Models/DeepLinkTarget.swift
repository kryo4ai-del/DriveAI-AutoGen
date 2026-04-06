enum DeepLinkTarget: Equatable {
    case home
    case category(id: String)
    case quiz(categoryId: String, questionId: String? = nil)
    case examSimulation
    case profile
    case settings
    
    /// Parse ASA/universal link with detailed logging
    static func parse(url: URL) -> Self? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            logParseError("URLComponents failed", url: url)
            return nil
        }
        
        #if DEBUG
        print("[DeepLink] Parsing: \(url.absoluteString)")
        print("[DeepLink]   Scheme: \(components.scheme ?? "nil")")
        print("[DeepLink]   Host: \(components.host ?? "nil")")
        print("[DeepLink]   Path: \(components.path)")
        #endif
        
        let target = parseCustomScheme(components) ?? parseUniversalLink(components)
        
        if target == nil {
            logParseError("Unrecognized pattern", url: url, components: components)
        }
        
        return target
    }
    
    // MARK: - Private Parsers
    
    private static func parseCustomScheme(_ components: URLComponents) -> Self? {
        guard components.scheme == "driveai" else { return nil }
        guard let host = components.host else { return nil }
        
        let params = Dictionary(
            components.queryItems?.map { ($0.name, $0.value) } ?? [],
            uniquingKeysWith: { first, _ in first }
        )
        
        switch host.lowercased() {
        case "category":
            guard let id = params["id"], !id.isEmpty else {
                logParseError("Missing category id", params: params)
                return nil
            }
            return .category(id: id)
            
        case "quiz":
            guard let categoryId = params["category"], !categoryId.isEmpty else {
                logParseError("Missing quiz category", params: params)
                return nil
            }
            let questionId = params["question"]
            return .quiz(categoryId: categoryId, questionId: questionId)
            
        case "exam":
            return .examSimulation
        case "profile":
            return .profile
        case "settings":
            return .settings
        case "home", "":
            return .home
        default:
            logParseError("Unknown host", params: ["host": host])
            return nil
        }
    }
    
    private static func parseUniversalLink(_ components: URLComponents) -> Self? {
        guard components.scheme == "https" else { return nil }
        
        let path = components.path.lowercased()
        let segments = path.components(separatedBy: "/").filter { !$0.isEmpty }
        
        // /category/{id}
        if let index = segments.firstIndex(of: "category"),
           index + 1 < segments.count {
            let id = segments[index + 1]
            return .category(id: id)
        }
        
        // /quiz/{categoryId}?q={questionId}
        if let index = segments.firstIndex(of: "quiz"),
           index + 1 < segments.count {
            let categoryId = segments[index + 1]
            let questionId = components.queryItems?.first(where: { $0.name == "q" })?.value
            return .quiz(categoryId: categoryId, questionId: questionId)
        }
        
        // /exam, /profile, /settings, /home
        if segments.contains("exam") { return .examSimulation }
        if segments.contains("profile") { return .profile }
        if segments.contains("settings") { return .settings }
        if segments.contains("home") || segments.isEmpty { return .home }
        
        return nil
    }
    
    // MARK: - Logging
    
    private static func logParseError(
        _ message: String,
        url: URL? = nil,
        components: URLComponents? = nil,
        params: [String: String]? = nil
    ) {
        #if DEBUG
        var log = "[DeepLink] ❌ \(message)"
        if let url = url {
            log += "\n[DeepLink]    URL: \(url.absoluteString)"
        }
        if let components = components {
            log += "\n[DeepLink]    Scheme: \(components.scheme ?? "nil")"
            log += "\n[DeepLink]    Host: \(components.host ?? "nil")"
            log += "\n[DeepLink]    Path: \(components.path)"
        }
        if let params = params {
            log += "\n[DeepLink]    Params: \(params)"
        }
        print(log)
        #endif
    }
}

// Add to AnalyticsEvent
extension AnalyticsEvent {
    case deepLinkHandled(target: DeepLinkTarget)
    
    var conversionValue: Int {
        switch self {
        case .deepLinkHandled(let target):
            switch target {
            case .category, .quiz:
                return 35  // High intent
            case .examSimulation:
                return 60  // Very high intent
            default:
                return 20
            }
        // ... existing cases
        default:
            return 0
        }
    }
}