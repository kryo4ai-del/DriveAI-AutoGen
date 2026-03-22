enum ExerciseSelectionError: LocalizedError, Sendable {
    case exerciseNotFound(id: UUID)
    case performanceDataMissing(id: UUID)
    case networkFailure(String)
    case cachingFailure(String)
    case invalidScore(Double)
    case invalidCompletionCount(Int)
    case concurrencyError(String)
    case decodingFailure(String)
}