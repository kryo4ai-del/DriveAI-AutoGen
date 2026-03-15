func calculateReadiness() async -> Result<ReadinessCalculationResult, ReadinessError> {
    do {
        // ... existing code
        return .success(ReadinessCalculationResult(...))
    } catch {
        return .failure(.calculationFailed(error))
    }
}

enum ReadinessError: LocalizedError {
    case calculationFailed(Error)
    case dataServiceUnavailable
    case invalidInput
}