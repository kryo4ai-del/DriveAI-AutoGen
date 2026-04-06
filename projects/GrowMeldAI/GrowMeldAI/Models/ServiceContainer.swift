// Services/Container.swift
import Foundation

/// Central service container for dependency injection
/// Provides single source of truth for all service instances
class ServiceContainer {
    static let shared = ServiceContainer()
    
    let questionProvider: QuestionDataProvider
    let progressTracker: ProgressTracker
    let spacedRepetitionEngine: SpacedRepetitionEngine
    
    // MARK: - Initialization
    
    init(
        questionProvider: QuestionDataProvider = LocalDataService.shared,
        progressTracker: ProgressTracker = UserProgressService.shared,
        spacedRepetitionEngine: SpacedRepetitionEngine = SpacedRepetitionService.shared
    ) {
        self.questionProvider = questionProvider
        self.progressTracker = progressTracker
        self.spacedRepetitionEngine = spacedRepetitionEngine
    }
    
    /// Create a container with mock services for testing
    static func mock(
        questionProvider: QuestionDataProvider = MockQuestionDataProvider(),
        progressTracker: ProgressTracker = MockProgressTracker(),
        spacedRepetitionEngine: SpacedRepetitionEngine = MockSpacedRepetitionEngine()
    ) -> ServiceContainer {
        ServiceContainer(
            questionProvider: questionProvider,
            progressTracker: progressTracker,
            spacedRepetitionEngine: spacedRepetitionEngine
        )
    }
}