import SwiftUI

@main
struct AskFinApp: App {
    @StateObject private var competenceService = TopicCompetenceService()
    @StateObject private var historyStore = SessionHistoryStore()

    var body: some Scene {
        WindowGroup {
            PremiumRootView(competenceService: competenceService, historyStore: historyStore)
                .environmentObject(historyStore)
        }
    }
}
