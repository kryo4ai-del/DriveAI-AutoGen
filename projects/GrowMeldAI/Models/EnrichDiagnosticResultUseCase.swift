// MARK: - UseCases/EnrichDiagnosticResultUseCase.swift

protocol EnrichDiagnosticResultUseCase {
    func execute(_ result: DiagnosticResult) async throws -> DiagnosticResult
}

final class EnrichDiagnosticResultUseCaseImpl: EnrichDiagnosticResultUseCase {
    private let recommendationsUseCase: GenerateRecommendationsUseCase
    private let actionsGenerator: InteractiveActionsGenerator
    
    func execute(_ result: DiagnosticResult) async throws -> DiagnosticResult {
        let recommendations = try await recommendationsUseCase.execute(for: result)
        let actions = actionsGenerator.generate(from: result, recommendations: recommendations)
        
        return DiagnosticResult(
            timestamp: result.timestamp,
            categoryStrengths: result.categoryStrengths,
            masteryCoverage: result.masteryCoverage,
            overallAccuracy: result.overallAccuracy,
            learningGaps: result.learningGaps,
            recommendations: recommendations,
            interactiveActions: actions
        )
    }
}