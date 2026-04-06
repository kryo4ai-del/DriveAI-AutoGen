import Foundation

/// Configuration for Meta Ads SDK
struct MetaAdsConfiguration: Codable, Sendable {
    let appID: String
    let clientToken: String
    let enableLogging: Bool
    let enableAutoLogAppEvents: Bool
    let enableAdvertiserIDCollection: Bool

    static let `default` = MetaAdsConfiguration(
        appID: "YOUR_APP_ID",
        clientToken: "YOUR_CLIENT_TOKEN",
        enableLogging: true,
        enableAutoLogAppEvents: true,
        enableAdvertiserIDCollection: true
    )
}