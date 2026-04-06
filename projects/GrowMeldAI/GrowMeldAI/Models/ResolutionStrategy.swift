// File: Domain/Services/ConflictResolutionService.swift

actor ConflictResolutionService {
    enum ResolutionStrategy {
        case lastWriteWins       // Remote wins
        case localWins           // Local cached wins
        case requireUserDecision // Pause sync, ask user
        case merge               // Attempt merge (if applicable)
    }
    
    func resolveAnswerConflict(
        local: UserAnswer,
        remote: UserAnswer,
        strategy: ResolutionStrategy
    ) async throws -> UserAnswer {
        switch strategy {
        case .lastWriteWins:
            return remote.timestamp > local.timestamp ? remote : local
        case .localWins:
            return local
        case .requireUserDecision:
            throw ResilienceError.sync(.conflictDetected(resourceId: local.id))
        case .merge:
            // Only applicable for progress aggregation
            return UserAnswer(
                id: local.id,
                questionId: local.questionId,
                selectedOption: local.selectedOption, // Keep local choice
                timestamp: max(local.timestamp, remote.timestamp),
                isFromCache: false
            )
        }
    }
}