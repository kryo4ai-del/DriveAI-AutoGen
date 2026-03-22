import SwiftUI

@main
struct BreathFlow3App: App {
    var body: some Scene {
        WindowGroup {
            ExerciseSelectionView(useCase: ExerciseSelectionUseCase(repository: AppDependencies.shared.exerciseRepository))
        }
    }
}
