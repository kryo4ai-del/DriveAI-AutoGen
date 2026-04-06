// Features/NotificationConsent/ViewModels/NotificationConsentViewModel.swift
import Foundation
import Combine

enum NotificationConsentState: Equatable {
    case idle
    case loading
    case presented
    case completed(ConsentDecision)
    case error(String)
}

protocol NotificationConsentViewModelProtocol: ObservableObject {
    var state: NotificationConsentState { get }
    var isSubmitting: Bool { get }
    func loadStoredConsent()
    func saveConsent(_ userConsented: Bool)
    func retryAfterError()
}

final class ConsoleLogger: Logger {
    func debug(_ message: String) {
        #if DEBUG
        print("[DEBUG] \(message)")
        #endif
    }

    func info(_ message: String) {
        print("[INFO] \(message)")
    }

    func error(_ message: String) {
        print("[ERROR] \(message)")
    }
}