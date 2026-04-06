import Foundation

protocol QuotaStore {
    func loadState() -> (FreemiumState, Date)
    func save(state: FreemiumState, resetDate: Date) async throws
}

enum QuotaError: Error, LocalizedError {
    case persistenceFailed(String)
    case loadFailed(String)

    var errorDescription: String? {
        switch self {
        case .persistenceFailed(let reason):
            return "Quota persistence failed: \(reason)"
        case .loadFailed(let reason):
            return "Quota load failed: \(reason)"
        }
    }
}

enum FreemiumState: Codable {
    case freeTierActive(questionsRemaining: Int)
    case premiumActive
    case freeTierExhausted

    private enum CodingKeys: String, CodingKey {
        case type, questionsRemaining
    }

    private enum StateType: String, Codable {
        case freeTierActive, premiumActive, freeTierExhausted
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .freeTierActive(let remaining):
            try container.encode(StateType.freeTierActive, forKey: .type)
            try container.encode(remaining, forKey: .questionsRemaining)
        case .premiumActive:
            try container.encode(StateType.premiumActive, forKey: .type)
        case .freeTierExhausted:
            try container.encode(StateType.freeTierExhausted, forKey: .type)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(StateType.self, forKey: .type)
        switch type {
        case .freeTierActive:
            let remaining = try container.decodeIfPresent(Int.self, forKey: .questionsRemaining) ?? 5
            self = .freeTierActive(questionsRemaining: remaining)
        case .premiumActive:
            self = .premiumActive
        case .freeTierExhausted:
            self = .freeTierExhausted
        }
    }
}

final class UserDefaultsQuotaStore: QuotaStore {
    private let defaults: UserDefaults
    private let stateKey = "freemium_state_v1"
    private let resetDateKey = "freemium_reset_date_v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadState() -> (FreemiumState, Date) {
        let state: FreemiumState = {
            guard let data = defaults.data(forKey: stateKey) else {
                return .freeTierActive(questionsRemaining: 5)
            }
            do {
                return try JSONDecoder().decode(FreemiumState.self, from: data)
            } catch {
                print("❌ Failed to decode quota state: \(error)")
                return .freeTierActive(questionsRemaining: 5)
            }
        }()

        let resetDate: Date = {
            if let timestamp = defaults.object(forKey: resetDateKey) as? TimeInterval {
                return Date(timeIntervalSince1970: timestamp)
            }
            return Date()
        }()

        return (state, resetDate)
    }

    func save(state: FreemiumState, resetDate: Date) async throws {
        do {
            let stateData = try JSONEncoder().encode(state)
            defaults.set(stateData, forKey: stateKey)
            defaults.set(resetDate.timeIntervalSince1970, forKey: resetDateKey)
            defaults.synchronize()
        } catch {
            throw QuotaError.persistenceFailed(error.localizedDescription)
        }
    }
}