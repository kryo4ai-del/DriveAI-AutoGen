// MARK: - App/DriverAIApp.swift
import SwiftUI

@main
struct DriverAIApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.light) // Or .dark based on user preference
        }
    }
}