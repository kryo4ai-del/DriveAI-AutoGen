// Services/PrivacyConsentService.swift
import Foundation
import Combine

@MainActor
final class PrivacyConsentService: ObservableObject {
    @Published private(set) var consentState: ConsentState = .unasked
    @Published private(set) var consentRecord: ConsentRecord?
    
    private let suiteName = "group.driveai.privacy"
    private let consentKey = "consentRecord"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init() {
        loadConsent()
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
    }
    
    func setConsent(_ state: ConsentState, userInitiated: Bool = true) {
        let record = ConsentRecord(
            state: state,
            timestamp: Date(),
            userInitiated: userInitiated
        )
        
        consentRecord = record
        consentState = state
        persist(record)
    }
    
    private func loadConsent() {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let data = defaults.data(forKey: consentKey) else {
            consentState = .unasked
            return
        }
        
        do {
            let record = try decoder.decode(ConsentRecord.self, from: data)
            consentRecord = record
            consentState = record.state
        } catch {
            print("❌ Failed to decode consent record: \(error)")
            consentState = .unasked
        }
    }
    
    private func persist(_ record: ConsentRecord) {
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            print("❌ UserDefaults suite unavailable")
            return
        }
        
        do {
            let data = try encoder.encode(record)
            defaults.set(data, forKey: consentKey)
            defaults.synchronize()
        } catch {
            print("❌ Failed to persist consent: \(error)")
        }
    }
    
    func resetConsent() {
        let defaults = UserDefaults(suiteName: suiteName)
        defaults?.removeObject(forKey: consentKey)
        defaults?.synchronize()
        consentState = .unasked
        consentRecord = nil
    }
}