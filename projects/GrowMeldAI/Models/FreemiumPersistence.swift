import Foundation

/// Protocol for persisting freemium state
public protocol FreemiumPersistence: Sendable {
    /// Save current daily state
    func saveDailyState(_ state: DailyLimitsState) async throws
    
    /// Load today's state, or nil if not yet initialized
    func loadDailyState() async throws -> DailyLimitsState?
    
    /// Save trial period configuration
    func saveTrialPeriod(_ period: TrialPeriod) async throws
    
    /// Load trial period, or nil if not set
    func loadTrialPeriod() async throws -> TrialPeriod?
    
    /// Clear all freemium data (for testing or reset)
    func clearAllData() async throws
}

/// Default in-memory + UserDefaults implementation
public actor DefaultFreemiumPersistence: FreemiumPersistence {
    private let userDefaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    private let dailyStateKey = "driveai.freemium.daily_state"
    private let trialPeriodKey = "driveai.freemium.trial_period"
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }
    
    public func saveDailyState(_ state: DailyLimitsState) async throws {
        let data = try encoder.encode(state)
        userDefaults.set(data, forKey: dailyStateKey)
    }
    
    public func loadDailyState() async throws -> DailyLimitsState? {
        guard let data = userDefaults.data(forKey: dailyStateKey) else {
            return nil
        }
        return try decoder.decode(DailyLimitsState.self, from: data)
    }
    
    public func saveTrialPeriod(_ period: TrialPeriod) async throws {
        let data = try encoder.encode(period)
        userDefaults.set(data, forKey: trialPeriodKey)
    }
    
    public func loadTrialPeriod() async throws -> TrialPeriod? {
        guard let data = userDefaults.data(forKey: trialPeriodKey) else {
            return nil
        }
        return try decoder.decode(TrialPeriod.self, from: data)
    }
    
    public func clearAllData() async throws {
        userDefaults.removeObject(forKey: dailyStateKey)
        userDefaults.removeObject(forKey: trialPeriodKey)
    }
}