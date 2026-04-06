// Services/SearchAds/SearchAdsService.swift

import AdServices
import os.log

protocol SearchAdsAttributionProvider {
    func fetchAttributionToken() async throws -> String
}

enum SearchAdsError: LocalizedError {
    case unavailable
    case tokenFetchFailed(String)
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .unavailable:
            return "Search Ads SDK not available on this device"
        case .tokenFetchFailed(let reason):
            return "Failed to fetch attribution token: \(reason)"
        case .permissionDenied:
            return "User denied Search Ads attribution permission"
        }
    }
}

final class SearchAdsService: SearchAdsAttributionProvider {
    private let logger = Logger(subsystem: "com.driveai.searchads", category: "SearchAdsService")
    
    nonisolated static let shared = SearchAdsService()
    
    private init() {}
    
    /// Fetch attribution token from Apple Search Ads
    /// - Returns: Attribution token string, or empty string if SDK unavailable
    /// - Throws: SearchAdsError on permission/network issues
    func fetchAttributionToken() async throws -> String {
        guard #available(iOS 14.3, *) else {
            logger.debug("Search Ads SDK not available (requires iOS 14.3+)")
            throw SearchAdsError.unavailable
        }
        
        do {
            let token = try await AdServices.attribution.token()
            logger.debug("Attribution token fetched successfully (length: \(token.count))")
            return token
        } catch let error as NSError {
            // Handle specific AdServices errors
            if error.domain == "ADClientError" {
                switch error.code {
                case 1: // ADClientErrorUnknown
                    logger.warning("AdServices error: unknown")
                    throw SearchAdsError.tokenFetchFailed("Unknown error")
                case 2: // ADClientErrorTrackingRestrictedOrDenied
                    logger.warning("AdServices error: tracking restricted")
                    throw SearchAdsError.permissionDenied
                default:
                    logger.warning("AdServices error: code \(error.code)")
                    throw SearchAdsError.tokenFetchFailed("Code: \(error.code)")
                }
            }
            
            logger.error("Attribution token fetch failed: \(error.localizedDescription)")
            throw SearchAdsError.tokenFetchFailed(error.localizedDescription)
        }
    }
}