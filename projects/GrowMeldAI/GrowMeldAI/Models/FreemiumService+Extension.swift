#if DEBUG
extension FreemiumService {
    public func resetForTesting() async throws {
        cachedDailyState = DailyLimitsState(date: Date())
        cachedTrialPeriod = TrialPeriod(durationDays: 14)!
        try await persistence.clearAllData()
    }
}
#endif