import Foundation

enum DeepLinkDestination: Hashable {
    case onboarding
    case dashboard
    case category(id: String)
    case categoryDetail(id: String)
    case examSimulation
    case question(id: String)
    case profile
    case examResult(sessionId: String)
    
    static func parse(url: URL) -> DeepLinkDestination? {
        guard let scheme = url.scheme, scheme == "driveai" else { return nil }
        
        let host = url.host ?? ""
        let pathComponents = url.pathComponents.filter { !$0.isEmpty && $0 != "/" }
        
        switch host {
        case "category":
            let categoryId = pathComponents.first ?? ""
            return categoryId.isEmpty ? nil : .category(id: categoryId)
        case "exam":
            return .examSimulation
        case "question":
            let questionId = pathComponents.first ?? ""
            return questionId.isEmpty ? nil : .question(id: questionId)
        case "profile":
            return .profile
        default:
            return .dashboard
        }
    }
    
    // For web deep links: https://driveai.de/de/category/verkehrszeichen
    static func parseUniversalLink(url: URL) -> DeepLinkDestination? {
        let pathComponents = url.pathComponents.filter { !$0.isEmpty && $0 != "/" }
        
        guard pathComponents.count >= 2 else { return .dashboard }
        
        // Skip language code (de, en, etc)
        let startIndex = pathComponents[0].count == 2 ? 1 : 0
        
        guard startIndex < pathComponents.count else { return .dashboard }
        
        switch pathComponents[startIndex] {
        case "category":
            let categoryId = pathComponents.count > startIndex + 1 ? pathComponents[startIndex + 1] : ""
            return categoryId.isEmpty ? nil : .category(id: categoryId)
        case "exam-simulator":
            return .examSimulation
        case "question":
            let questionId = pathComponents.count > startIndex + 1 ? pathComponents[startIndex + 1] : ""
            return questionId.isEmpty ? nil : .question(id: questionId)
        case "profile":
            return .profile
        default:
            return .dashboard
        }
    }
}