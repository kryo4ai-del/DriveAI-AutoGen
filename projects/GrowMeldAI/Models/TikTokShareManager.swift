// TikTokShareManager.swift
import Foundation
import UIKit

/// Manager for TikTok sharing operations
/// This is intentionally minimal to avoid any data sharing concerns
final class TikTokShareManager {

    private let deepLinkService: TikTokDeepLinkService

    init(deepLinkService: TikTokDeepLinkService = TikTokDeepLinkService()) {
        self.deepLinkService = deepLinkService
    }

    /// Prepares content for sharing to TikTok
    /// - Parameter caption: Optional caption text
    /// - Parameter url: URL to share
    /// - Returns: Shareable content object
    func prepareShareContent(caption: String = "", url: URL) -> TikTokShareableContent {
        return TikTokShareableContent(caption: caption, url: url)
    }

    /// Shares content to TikTok if available
    /// - Parameter content: Content to share
    func share(content: TikTokShareableContent) {
        let tikTokURL = deepLinkService.deepLink(for: content)
        UIApplication.shared.open(tikTokURL)
    }
}