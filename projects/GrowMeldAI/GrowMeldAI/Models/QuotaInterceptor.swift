// Features/Question/QuotaInterceptor.swift
import Foundation

@MainActor
struct QuotaInterceptor {
    @Environment(\.quotaManager) var quotaManager

    /// Check if user can proceed to answer a question
    /// - Returns: Result indicating success or failure with appropriate error
    func canProceedToQuestion() -> Result<Void, QuotaError> {
        guard quotaManager.state.canAnswerQuestion else {
            return .failure(.quotaExhausted)
        }
        return .success(())
    }

    /// Commit the consumption of a question
    /// - Throws: QuotaError if consumption fails
    func commitQuestion() async throws {
        try await quotaManager.consumeQuestion()
    }
}