// MARK: - Services/DeepLinkService.swift
import Foundation

@MainActor
final class DeepLinkService {
    static let shared = DeepLinkService()
    private let analyticsService = AnalyticsService.shared
    
    func handleDeepLink(_ url: URL) -> DeepLinkDestination? {
        // Extract and store UTM parameters for analytics
        analyticsService.setUTMParameters(from: url)
        
        // Handle custom scheme: driveai://category/verkehrszeichen
        if url.scheme == "driveai" {
            return parseCustomScheme(url)
        }
        
        // Handle universal links: https://driveai.de/de/category/verkehrszeichen
        if isValidUniversalLinkHost(url) {
            return DeepLinkDestination.parseUniversalLink(url: url)
        }
        
        return nil
    }
    
    private func parseCustomScheme(_ url: URL) -> DeepLinkDestination? {
        // Let the model handle parsing
        return DeepLinkDestination.parse(url: url)
    }
    
    private func isValidUniversalLinkHost(_ url: URL) -> Bool {
        guard let host = url.host else { return false }
        return host.contains("driveai.de") || host.contains("driveai.app")
    }
}