// MARK: - FirebaseManager.swift
// Purpose: Centralized Firebase SDK initialization and configuration

import Foundation

// MARK: - Firebase Availability Shims
// Firebase modules are conditionally available; use availability checks

#if canImport(FirebaseCore)
import FirebaseCore
#endif

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif

#if canImport(FirebaseCrashlytics)
import FirebaseCrashlytics
#endif

// MARK: - AppLogger Shim (if not defined elsewhere)

private struct AppLogger {
    func info(_ message: String) {
        #if DEBUG
        print("[FirebaseManager] ℹ️ \(message)")
        #endif
    }

    func error(_ message: String) {
        print("[FirebaseManager] ❌ \(message)")
    }
}

// MARK: - FirebaseManager

final class FirebaseManager {
    static let shared = FirebaseManager()

    private let logger = AppLogger()

    private init() {
        #if canImport(FirebaseCore)
        // Firebase configuration happens in FirebaseApp.configure() during AppDependencies init
        if FirebaseApp.app() != nil {
            logger.info("FirebaseManager initialized with existing FirebaseApp")
        } else {
            logger.info("FirebaseManager initialized — FirebaseApp not yet configured")
        }
        #else
        logger.info("FirebaseManager initialized (FirebaseCore unavailable)")
        #endif
    }

    // MARK: - Firebase App

    var firebaseApp: AnyObject? {
        #if canImport(FirebaseCore)
        return FirebaseApp.app()
        #else
        return nil
        #endif
    }

    // MARK: - Crash Reporting

    /// Enable Crashlytics error reporting (GDPR-compliant)
    func enableCrashReporting() {
        #if !DEBUG
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        logger.info("Crashlytics enabled")
        #endif
        #endif
    }

    /// Log custom error to Crashlytics (respects user consent)
    func logError(_ error: Error, context: String = "") {
        let message = context.isEmpty
            ? error.localizedDescription
            : "\(context): \(error.localizedDescription)"
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().record(error: error)
        #endif
        logger.error(message)
    }

    // MARK: - Analytics

    /// Log a named analytics event
    func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent(name, parameters: parameters)
        #endif
    }

    // MARK: - Auth

    /// Get Firebase Auth instance (optional to handle missing SDK gracefully)
    var auth: AnyObject? {
        #if canImport(FirebaseAuth)
        return Auth.auth()
        #else
        return nil
        #endif
    }

    // MARK: - Firestore

    /// Get Firestore database instance (optional to handle missing SDK gracefully)
    var firestore: AnyObject? {
        #if canImport(FirebaseFirestore)
        return Firestore.firestore()
        #else
        return nil
        #endif
    }
}

// MARK: - Typed Accessors (available when SDKs are present)

#if canImport(FirebaseAuth)
extension FirebaseManager {
    /// Typed Firebase Auth accessor
    var typedAuth: Auth {
        return Auth.auth()
    }
}
#endif

#if canImport(FirebaseFirestore)
extension FirebaseManager {
    /// Typed Firestore accessor
    var typedFirestore: Firestore {
        return Firestore.firestore()
    }
}
#endif