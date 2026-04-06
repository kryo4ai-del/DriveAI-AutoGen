// TikTokShareableContent.swift
import Foundation

/// Represents content that can be shared to TikTok
/// This is intentionally minimal to avoid any data sharing concerns
struct TikTokShareableContent: Equatable {
    let caption: String
    let url: URL

    init(caption: String = "", url: URL) {
        self.caption = caption
        self.url = url
    }
}