// File: Models/ConsentManager.swift
import Foundation
import Combine

/// Protocol for consent management
protocol ConsentManagerProtocol {
    var hasConsent: Bool { get }
    var consentChanged: AnyPublisher<Bool, Never> { get }
    func setConsent(_ granted: Bool)
}

/// Manages user consent for crash reporting with persistence