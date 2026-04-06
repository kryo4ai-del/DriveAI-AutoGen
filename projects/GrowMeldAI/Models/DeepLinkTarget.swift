import Foundation

enum DeepLinkTarget: Equatable {
    case home
    case category(id: String)
    case quiz(categoryId: String, questionId: String? = nil)
    case examSimulation
    case profile
    case settings

    static func parse(url: URL) -> Self? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            #if DEBUG
            print("[DeepLink] ❌ URLComponents failed for: \(url.absoluteString)")
            #endif
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
            #if DEBUG
            print("[DeepLink] ❌ Unrecognized pattern for: \(url.absoluteString)")
            #endif
        }

        return target
    }

    // MARK: - Private Parsers

    private static func parseCustomScheme(_ components: URLComponents) -> Self? {
        guard components.scheme == "driveai" else { return nil }
        guard let host = components.host else { return nil }

        var params: [String: String?] = [:]
        for item in components.queryItems ?? [] {
            params[item.name] = item.value
        }

        switch host.lowercased() {
        case "category":
            guard let id = params["id"] as? String, !id.isEmpty else {
                #if DEBUG
                print("[DeepLink] ❌ Missing category id")
                #endif
                return nil
            }
            return .category(id: id)

        case "quiz":
            guard let categoryId = params["category"] as? String, !categoryId.isEmpty else {
                #if DEBUG
                print("[DeepLink] ❌ Missing quiz category")
                #endif
                return nil
            }
            let questionId = params["question"] as? String
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
            #if DEBUG
            print("[DeepLink] ❌ Unknown host: \(host)")
            #endif
            return nil
        }
    }

    private static func parseUniversalLink(_ components: URLComponents) -> Self? {
        guard components.scheme == "https" else { return nil }

        let path = components.path.lowercased()
        let segments = path.components(separatedBy: "/").filter { !$0.isEmpty }

        if let index = segments.firstIndex(of: "category"),
           index + 1 < segments.count {
            let id = segments[index + 1]
            return .category(id: id)
        }

        if let index = segments.firstIndex(of: "quiz"),
           index + 1 < segments.count {
            let categoryId = segments[index + 1]
            let questionId = components.queryItems?.first(where: { $0.name == "q" })?.value
            return .quiz(categoryId: categoryId, questionId: questionId)
        }

        if segments.contains("exam") { return .examSimulation }
        if segments.contains("profile") { return .profile }
        if segments.contains("settings") { return .settings }
        if segments.contains("home") || segments.isEmpty { return .home }

        return nil
    }
}