// AskFinPremiumApp.swift
// Entry point for AskFin Premium.
//
// Initializes shared services and injects them into the view hierarchy.
// All services are created once here and passed down — no singletons.

import SwiftUI

@main
struct AskFinPremiumApp: App {

    // MARK: - Shared Services

    @StateObject private var competenceService = TopicCompetenceService()

    var body: some Scene {
        WindowGroup {
            RootView(competenceService: competenceService)
                .preferredColorScheme(.dark)
        }
    }
}
