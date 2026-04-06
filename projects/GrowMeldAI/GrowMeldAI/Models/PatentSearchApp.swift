// PatentSearchApp.swift
import SwiftUI

@main
struct PatentSearchApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            PatentSearchView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}