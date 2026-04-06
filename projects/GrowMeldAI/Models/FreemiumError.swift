public enum FreemiumError: LocalizedError {
    case invalidTrialDuration
    case invalidDailyLimits
    case persistenceFailure(String)
    case dateCalculationFailed
    case stateCorrupted
}