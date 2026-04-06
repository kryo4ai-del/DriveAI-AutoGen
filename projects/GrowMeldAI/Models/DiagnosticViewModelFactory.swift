// MARK: - Services/Factory/DiagnosticViewModelFactory.swift

final class DiagnosticViewModelFactory {
    private let progressRepository: ProgressRepository
    private let questionRepository: QuestionRepository
    
    init(
        progressRepository: ProgressRepository,
        questionRepository: QuestionRepository
    ) {
        self.progressRepository = progressRepository
        self.questionRepository = questionRepository
    }
    
    func makeDiagnosticViewModel() -> DiagnosticViewModel {
        let diagnoseUseCase = DiagnoseUserStrengthsUseCaseImpl(
            progressRepository: progressRepository,
            questionRepository: questionRepository
        )
        let recommendationsUseCase = GenerateRecommendationsUseCaseImpl()
        
        return DiagnosticViewModel(
            diagnoseUseCase: diagnoseUseCase,
            recommendationsUseCase: recommendationsUseCase
        )
    }
}