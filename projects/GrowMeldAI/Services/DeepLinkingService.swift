import Foundation
import os.log
import Combine

@MainActor
class DeepLinkingService: ObservableObject {
    private let logger = Logger(subsystem: "com.driveai.deeplink", category: "DeepLinking")
    
    // Validation patterns
    private let uuidPattern = try! NSRegularExpression(
        pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$",
        options: .caseInsensitive
    )
    
    private let categoryPattern = try! NSRegularExpression(
        pattern: "^[a-z0-9_-]{3,50}$",
        options: .caseInsensitive
    )
    
    // MARK: - Deep Link Handling
    
    func handleDeepLink(_ url: URL) -> DeepLinkDestination? {
        guard url.scheme == "driveai" else {
            logger.warning("Invalid scheme: \(url.scheme ?? "nil")")
            return nil
        }
        
        let pathComponents = url.pathComponents.filter { !$0.isEmpty && $0 != "/" }
        
        guard pathComponents.count >= 1 else {
            logger.warning("Invalid path components")
            return nil
        }
        
        let path = pathComponents[0]
        let parameter = pathComponents.count > 1 ? pathComponents[1] : nil
        
        switch path {
        case "question":
            guard let questionID = parameter, isValidUUID(questionID) else {
                logger.warning("Invalid question ID: \(parameter ?? "nil")")
                return nil
            }
            logger.info("Routing to question: \(questionID)")
            return .question(id: questionID)
            
        case "category":
            guard let categoryName = parameter, isValidCategory(categoryName) else {
                logger.warning("Invalid category: \(parameter ?? "nil")")
                return nil
            }
            logger.info("Routing to category: \(categoryName)")
            return .category(id: categoryName)
            
        case "exam":
            logger.info("Routing to exam simulation")
            return .examSimulation
            
        default:
            logger.warning("Unknown deep link path: \(path)")
            return nil
        }
    }
    
    // MARK: - Validation
    
    private func isValidUUID(_ string: String) -> Bool {
        let range = NSRange(string.startIndex..<string.endIndex, in: string)
        let matches = uuidPattern.numberOfMatches(in: string, range: range)
        return matches > 0
    }
    
    private func isValidCategory(_ string: String) -> Bool {
        let range = NSRange(string.startIndex..<string.endIndex, in: string)
        let matches = categoryPattern.numberOfMatches(in: string, range: range)
        return matches > 0
    }
    
    // MARK: - URL Creation (safe)
    
    func createDeepLink(for destination: DeepLinkDestination) -> URL? {
        var components = URLComponents()
        components.scheme = "driveai"
        
        switch destination {
        case .question(let id):
            guard isValidUUID(id) else { return nil }
            components.path = "/question/\(id)"
            
        case .category(let name):
            guard isValidCategory(name) else { return nil }
            components.path = "/category/\(name)"
            
        case .examSimulation:
            components.path = "/exam"
        case .profile:
            components.path = "/profile"
        case .dashboard:
            components.path = "/dashboard"
        default:
            components.path = "/"
        }
        
        return components.url
    }
}

// MARK: - Destination Types

// Enum DeepLinkDestination declared in Models/DeepLinkDestination.swift
