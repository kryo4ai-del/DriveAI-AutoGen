// Core/DependencyInjection/ModuleFactory.swift

class QuickAccessModuleFactory {
    static func makeQuickAccessService(
        exerciseSelection: ExerciseSelectionService,
        quizProgress: QuizProgressService,
        auth: AuthService,
        analytics: AnalyticsService
    ) -> QuickAccessService {
        DefaultQuickAccessService(
            exerciseSelectionService: exerciseSelection,
            quizProgressService: quizProgress,
            authService: auth,
            analyticsService: analytics
        )
    }
    
    static func makeCoordinator(
        service: QuickAccessService
    ) -> QuickAccessCoordinator {
        QuickAccessCoordinator(quickAccessService: service)
    }
    
    static func makeButtonViewModel(
        coordinator: QuickAccessCoordinator,
        userState: UserState
    ) -> QuickAccessButtonViewModel {
        QuickAccessButtonViewModel(
            coordinator: coordinator,
            userState: userState
        )
    }
}