// Features/Freemium/Stores/UserDefaultsQuotaStore.swift

import Foundation

/// UserDefaults-backed quota persistence
final class UserDefaultsQuotaStore: QuotaStore {
    private let defaults: UserDefaults
    private let stateKey = "freemium_state_v1"
    private let resetDateKey = "freemium_reset_date_v1"
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    // MARK: - QuotaStore Conformance
    
    func loadState() -> (FreemiumState, Date) {
        // Load state
        let state: FreemiumState = {
            guard let data = defaults.data(forKey: stateKey) else {
                // Default: 5 questions/day free tier
                return .freeTierActive(questionsRemaining: 5)
            }
            
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(FreemiumState.self, from: data)
            } catch {
                print("❌ Failed to decode quota state: \(error)")
                return .freeTierActive(questionsRemaining: 5)
            }
        }()
        
        // Load reset date
        let resetDate: Date = {
            if let timestamp = defaults.object(forKey: resetDateKey) as? TimeInterval {
                return Date(timeIntervalSince1970: timestamp)
            }
            return .now
        }()
        
        return (state, resetDate)
    }
    
    func save(state: FreemiumState, resetDate: Date) async throws {
        let encoder = JSONEncoder()
        
        do {
            let stateData = try encoder.encode(state)
            defaults.set(stateData, forKey: stateKey)
            defaults.set(resetDate.timeIntervalSince1970, forKey: resetDateKey)
            
            // Synchronize to disk (important for quota data)
            defaults.synchronize()
        } catch {
            throw QuotaError.persistenceFailed(error.localizedDescription)
        }
    }
}

// MARK: - Testing: MockQuotaStore

/// Mock store for unit testing (doesn't persist)