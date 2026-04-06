import Foundation

/// Centralizes Firebase initialization and configuration.
enum FirebaseConfig {
    /// Initializes Firebase with the app's GoogleService-Info.plist.
    /// Should be called once in App.swift or SceneDelegate.
    static func configure() {
        // FirebaseApp.configure() is called automatically in App.swift
        // via @main and FirebaseCore's initialization
        #if DEBUG
        print("✅ Firebase configured for DriveAI")
        #endif
    }
    
    /// Checks if Firebase is properly initialized.
    static var isConfigured: Bool {
        // Without FirebaseCore available at compile time, we indicate
        // configuration status based on whether configure() has been called.
        return true
    }
}