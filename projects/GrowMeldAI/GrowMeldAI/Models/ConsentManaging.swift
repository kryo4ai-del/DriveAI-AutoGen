// MARK: - Services/Consent/ConsentManager.swift

import Foundation
import Combine
import Security

protocol ConsentManaging: AnyObject {
    var hasUserConsent: Bool { get }
    var consentStatus: ConsentStatus { get }
    var consentStatusPublisher: AnyPublisher<ConsentStatus, Never> { get }
    
    func requestConsent() async -> Bool
    func revokeConsent() async
}

@MainActor

// MARK: - Helper Extension (for DispatchQueue.async compatibility)

extension DispatchQueue {
    func async<T>(
        group: DispatchGroup? = nil,
        qos: DispatchQoS = .unspecified,
        flags: DispatchWorkItemFlags = [],
        execute work: @escaping @Sendable () -> T
    ) async -> T {
        await withCheckedContinuation { continuation in
            self.async(group: group, qos: qos, flags: flags) {
                continuation.resume(returning: work())
            }
        }
    }
}