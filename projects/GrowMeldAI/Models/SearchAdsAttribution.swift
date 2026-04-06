import Foundation
import UIKit
struct SearchAdsAttribution: Codable, Equatable {
    let token: String
    let fetchedAt: Date
    let sessionId: String  // App session identifier
    let campaignId: String?
    let isValid: Bool
    
    /// Token valid only within same app session AND within 5 minutes
    var isFresh: Bool {
        let age = Date().timeIntervalSince(fetchedAt)
        let isAppActive = UIApplication.shared.applicationState == .active
        let sessionStillActive = sessionId == AppSession.current.id
        
        return age < 300 && isAppActive && sessionStillActive  // 5 min max
    }
}

// Track app session changes
final class AppSession {
    static let current = AppSession()
    
    private(set) var id: String = UUID().uuidString
    
    func invalidate() {
        id = UUID().uuidString  // Force new session
    }
}

final class SearchAdsAttributionCache {
    private var memoryCache: SearchAdsAttribution?
    private let defaults = UserDefaults.standard
    private let cacheKey = "searchads.attribution.cache"
    
    static let shared = SearchAdsAttributionCache()
    
    private init() {
        // Listen for app background/foreground to invalidate cache
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    func getCachedAttribution() -> SearchAdsAttribution? {
        // Memory cache: return if fresh AND same session
        if let cached = memoryCache, cached.isFresh {
            return cached
        }
        
        // Persistent cache (UserDefaults): only return if fresh
        guard let data = defaults.data(forKey: cacheKey),
              let cached = try? JSONDecoder().decode(SearchAdsAttribution.self, from: data),
              cached.isFresh else {
            return nil
        }
        
        memoryCache = cached
        return cached
    }
    
    func cacheAttribution(_ attribution: SearchAdsAttribution) {
        memoryCache = attribution
        if let encoded = try? JSONEncoder().encode(attribution) {
            defaults.set(encoded, forKey: cacheKey)
        }
    }
    
    func clearCache() {
        memoryCache = nil
        defaults.removeObject(forKey: cacheKey)
    }
    
    @objc private func appDidEnterBackground() {
        AppSession.current.invalidate()
        clearCache()  // Force refresh on next foreground
    }
    
    @objc private func appDidBecomeActive() {
        AppSession.current.invalidate()
    }
}