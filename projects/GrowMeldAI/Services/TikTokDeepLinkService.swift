// TikTokDeepLinkService.swift
import Foundation
import UIKit

/// Service for generating TikTok deep links
/// Uses only URL scheme approach - no API calls or data sharing
final class TikTokDeepLinkService {

    // TikTok URL scheme constants
    private enum Constants {
        static let tikTokAppURLScheme = "tiktok://"
        static let tikTokWebURL = URL(string: "https://www.tiktok.com/")!
    }

    /// Generates a deep link URL for TikTok
    /// - Parameter content: The content to share
    /// - Returns: URL to open TikTok app or web fallback
    func deepLink(for content: TikTokShareableContent) -> URL {
        // Construct a simple deep link that opens TikTok
        // Note: This doesn't share any content automatically - user must manually create post
        guard let url = URL(string: Constants.tikTokAppURLScheme) else {
            return Constants.tikTokWebURL
        }
        return url
    }

    /// Checks if TikTok app is installed
    /// - Returns: Boolean indicating if TikTok is available
    func isTikTokInstalled() -> Bool {
        // Simple check for TikTok URL scheme availability
        // This is the safest approach that doesn't require any data sharing
        return UIApplication.shared.canOpenURL(URL(string: Constants.tikTokAppURLScheme)!)
    }
}