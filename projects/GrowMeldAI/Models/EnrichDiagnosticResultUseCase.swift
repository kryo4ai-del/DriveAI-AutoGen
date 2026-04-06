import Foundation

// MARK: - Protocol

protocol EnrichDiagnosticResultUseCase {
    func execute(_ result: DiagnosticResult) async throws -> DiagnosticResult
}

// MARK: - Implementation

final class EnrichDiagnosticResultUseCaseImpl: EnrichDiagnosticResultUseCase {
    private let recommendationsUseCase: GenerateRecommendationsUseCase

    init(recommendationsUseCase: GenerateRecommendationsUseCase) {
        self.recommendationsUseCase = recommendationsUseCase
    }

    func execute(_ result: DiagnosticResult) async throws -> DiagnosticResult {
        let recommendations = try await recommendationsUseCase.execute(for: result)
        return DiagnosticResult(recommendations: recommendations)
    }
}