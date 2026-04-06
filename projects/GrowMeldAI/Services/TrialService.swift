import Foundation

// MARK: - Trial Persistence

private struct TrialData: Codable {
    var trialStartDate: Date?
    var trialEndDate: Date?
    var hasStartedTrial: Bool
    var hasConvertedToPaid: Bool
    var featureUsageCounts: [String: Int]
}

private final class TrialPersistence {
    private let userDefaults: UserDefaults
    private let storageKey = "com.growmeld.trial.data"

    static let shared = TrialPersistence()

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func save(_ data: TrialData) {
        if let encoded = try? JSONEncoder().encode(data) {
            userDefaults.set(encoded, forKey: storageKey)
        }
    }

    func load() -> TrialData {
        guard let data = userDefaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(TrialData.self, from: data) else {
            return TrialData(
                trialStartDate: nil,
                trialEndDate: nil,
                hasStartedTrial: false,
                hasConvertedToPaid: false,
                featureUsageCounts: [:]
            )
        }
        return decoded
    }

    func clear() {
        userDefaults.removeObject(forKey: storageKey)
    }
}

// MARK: - Trial Status

enum TrialStatus: Equatable {
    case notStarted
    case active(daysRemaining: Int)
    case expired
    case converted
}

// MARK: - Trial Configuration

struct TrialConfiguration {
    let durationDays: Int
    let featureLimits: [String: Int]

    static let `default` = TrialConfiguration(
        durationDays: 14,
        featureLimits: [
            "ai_explanations": 10,
            "practice_tests": 5,
            "progress_reports": 3
        ]
    )
}

// MARK: - Trial Service

@MainActor
final class TrialService: ObservableObject {

    // MARK: - Published State

    @Published private(set) var status: TrialStatus = .notStarted
    @Published private(set) var daysRemaining: Int = 0
    @Published private(set) var featureUsageCounts: [String: Int] = [:]

    // MARK: - Dependencies

    private let persistence: TrialPersistence
    private let configuration: TrialConfiguration
    private var refreshTimer: Timer?

    // MARK: - Init

    init(
        persistence: TrialPersistence = .shared,
        configuration: TrialConfiguration = .default
    ) {
        self.persistence = persistence
        self.configuration = configuration
        refreshStatus()
        startRefreshTimer()
    }

    deinit {
        refreshTimer?.invalidate()
    }

    // MARK: - Public API

    /// Start the trial period for this user
    func startTrial() {
        var data = persistence.load()
        guard !data.hasStartedTrial else { return }

        let now = Date()
        let end = Calendar.current.date(
            byAdding: .day,
            value: configuration.durationDays,
            to: now
        ) ?? now

        data.trialStartDate = now
        data.trialEndDate = end
        data.hasStartedTrial = true
        data.hasConvertedToPaid = false
        data.featureUsageCounts = [:]

        persistence.save(data)
        refreshStatus()
    }

    /// Mark the user as having converted to a paid plan
    func convertToPaid() {
        var data = persistence.load()
        data.hasConvertedToPaid = true
        persistence.save(data)
        refreshStatus()
    }

    /// Track usage of a gated feature; returns false if limit reached
    @discardableResult
    func trackFeatureUsage(_ featureKey: String) -> Bool {
        let data = persistence.load()

        guard canUseFeature(featureKey) else {
            return false
        }

        var updatedData = data
        updatedData.featureUsageCounts[featureKey, default: 0] += 1
        persistence.save(updatedData)
        featureUsageCounts = updatedData.featureUsageCounts

        return true
    }

    /// Check whether a feature is accessible in the current trial state
    func canUseFeature(_ featureKey: String) -> Bool {
        let data = persistence.load()

        // Paid users always have access
        if data.hasConvertedToPaid { return true }

        // Not in an active trial
        guard case .active = status else { return false }

        // Check feature-specific usage limits
        if let limit = configuration.featureLimits[featureKey] {
            let used = data.featureUsageCounts[featureKey] ?? 0
            return used < limit
        }

        // No limit defined → allow
        return true
    }

    /// Remaining uses for a given feature; nil if unlimited or not applicable
    func remainingUses(for featureKey: String) -> Int? {
        guard let limit = configuration.featureLimits[featureKey] else { return nil }
        let data = persistence.load()
        let used = data.featureUsageCounts[featureKey] ?? 0
        return max(0, limit - used)
    }

    /// Reset all trial state (e.g., for testing / sign-out)
    func resetTrial() {
        persistence.clear()
        refreshStatus()
    }

    // MARK: - Private Helpers

    private func refreshStatus() {
        let data = persistence.load()
        featureUsageCounts = data.featureUsageCounts

        if data.hasConvertedToPaid {
            status = .converted
            daysRemaining = 0
            return
        }

        guard data.hasStartedTrial, let endDate = data.trialEndDate else {
            status = .notStarted
            daysRemaining = 0
            return
        }

        let now = Date()
        if now >= endDate {
            status = .expired
            daysRemaining = 0
        } else {
            let remaining = Calendar.current.dateComponents(
                [.day],
                from: now,
                to: endDate
            ).day ?? 0
            daysRemaining = max(0, remaining)
            status = .active(daysRemaining: daysRemaining)
        }
    }

    private func startRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(
            withTimeInterval: 60 * 60, // refresh every hour
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refreshStatus()
            }
        }
    }
}