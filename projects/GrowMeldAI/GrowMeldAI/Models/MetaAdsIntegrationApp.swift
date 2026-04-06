import SwiftUI

@main
struct MetaAdsIntegrationApp: App {
    @StateObject private var consentManager = MetaAdsConsentManager()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                VertrauensCheckView(consentManager: consentManager)
            }
        }
    }
}