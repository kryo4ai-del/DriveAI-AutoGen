import SwiftUI

@main
struct AskFinApp: App {
    @StateObject private var competenceService = TopicCompetenceService()

    var body: some Scene {
        WindowGroup {
            PremiumRootView(competenceService: competenceService)
        }
    }
}
