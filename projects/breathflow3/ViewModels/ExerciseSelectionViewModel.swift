// ViewModels/ExerciseSelectionViewModel.swift
import Foundation

@MainActor
class ExerciseSelectionViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var selectedExercise: Exercise?
    @Published var exerciseStats: [UUID: UserSessionStats] = [:]
    @Published var isLoading = false
    @Published var error: AppError?
    @Published var selectedCategory: ExerciseCategory?
    
    private let repository: ExerciseRepository
    private let statsService: SessionHistoryService
    private var loadTask: Task<Void, Never>?
    
    init(
        repository: ExerciseRepository = ExerciseRepository(),
        statsService: SessionHistoryService
    ) {
        self.repository = repository
        self.statsService = statsService
    }
    
    deinit {
        loadTask?.cancel()
    }
    
    func loadExercises() async {
        // Cancel previous load
        loadTask?.cancel()
        
        isLoading = true
        defer { isLoading = false }
        
        loadTask = Task {
            do {
                let loaded = try await repository.loadExercises()
                self.exercises = loaded
                self.error = nil
                
                // Load stats concurrently for all exercises
                await loadAllStats(for: loaded)
            } catch {
                self.error = error as? AppError ?? .unknown("\(error)")
                self.exercises = []
            }
        }
        
        await loadTask?.value
    }
    
    func filterByCategory(_ category: ExerciseCategory?) {
        selectedCategory = category
    }
    
    func selectExercise(_ exercise: Exercise) {
        selectedExercise = exercise
    }
    
    func clearError() {
        error = nil
    }
    
    // MARK: - Private
    
    private func loadAllStats(for exercises: [Exercise]) async {
        let stats = await statsService.getStatsForMultiple(
            exerciseIds: exercises.map { $0.id }
        )
        self.exerciseStats = stats
    }
    
    var filteredExercises: [Exercise] {
        guard let category = selectedCategory else {
            return exercises
        }
        return exercises.filter { $0.category == category }
    }
}