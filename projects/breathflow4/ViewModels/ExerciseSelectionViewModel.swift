import SwiftUI
import Combine

@MainActor
final class ExerciseSelectionViewModel: ObservableObject {
    @Published var exercises: [BreathingExercise] = []
    @Published var selectedCategory: ExerciseCategory? = nil
    @Published var loadingState: LoadingState = .idle
    @Published var selectedExercise: BreathingExercise? = nil
    
    enum LoadingState {
        case idle
        case loading
        case error(String)
    }
    
    private let dataProvider: ExerciseDataProvider
    private let analytics: AnalyticsService
    private var loadTask: Task<Void, Never>?
    
    init(
        dataProvider: ExerciseDataProvider = DefaultExerciseDataProvider.shared,
        analytics: AnalyticsService = .shared
    ) {
        self.dataProvider = dataProvider
        self.analytics = analytics
        Task { await loadExercises() }
    }
    
    deinit {
        loadTask?.cancel()
    }
    
    // MARK: - Computed Properties
    
    var filteredExercises: [BreathingExercise] {
        guard let category = selectedCategory else { return exercises }
        return exercises.filter { $0.category == category }
    }
    
    var isLoading: Bool {
        if case .loading = loadingState { return true }
        return false
    }
    
    var errorMessage: String? {
        if case .error(let msg) = loadingState { return msg }
        return nil
    }
    
    // MARK: - Public Methods
    
    func selectCategory(_ category: ExerciseCategory?) {
        selectedCategory = category
        withAnimation(.easeInOut(duration: 0.2)) {}
        analytics.track(event: .exerciseFiltered(
            category: category?.rawValue ?? "All"
        ))
    }
    
    func selectExercise(_ exercise: BreathingExercise) {
        selectedExercise = exercise
        analytics.track(event: .exerciseSelected(
            id: exercise.id.uuidString,
            name: exercise.name,
            category: exercise.category.rawValue
        ))
    }
    
    func clearSelection() {
        selectedExercise = nil
    }
    
    func refreshExercises() async {
        loadingState = .idle
        await loadExercises()
    }
    
    // MARK: - Private Methods
    
    private func loadExercises() async {
        loadTask?.cancel()
        loadTask = Task {
            loadingState = .loading
            
            do {
                exercises = try await dataProvider.fetchExercises()
                loadingState = .idle
                analytics.track(event: .exercisesLoaded(count: exercises.count))
            } catch is CancellationError {
                // Silently cancelled
            } catch {
                let errorMsg = (error as? LocalizedError)?.errorDescription
                    ?? error.localizedDescription
                loadingState = .error(errorMsg)
                analytics.track(event: .error(message: errorMsg))
            }
        }
    }
}