// ViewModels/ExerciseSelectionViewModel.swift
import SwiftUI

@MainActor
class ExerciseSelectionViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var selectedExercise: Exercise?
    @Published var exerciseStats: [UUID: UserSessionStats] = [:]
    @Published var isLoading = false
    @Published var error: AppError?
    @Published var selectedCategory: ExerciseCategory?
    @Published var state = ExerciseSelectionState()

    private let useCase: ExerciseSelectionUseCaseProtocol?
    private let repository: ExerciseRepositoryProtocol?
    private var loadTask: Task<Void, Never>?

    init(useCase: ExerciseSelectionUseCaseProtocol) {
        self.useCase = useCase
        self.repository = nil
    }

    init(repository: ExerciseRepositoryProtocol) {
        self.repository = repository
        self.useCase = nil
    }

    deinit {
        loadTask?.cancel()
    }

    func loadExercises() {
        loadTask?.cancel()

        isLoading = true
        state.isLoading = true

        loadTask = Task {
            defer {
                isLoading = false
                state.isLoading = false
            }

            do {
                let loaded: [Exercise]
                if let useCase = useCase {
                    loaded = try await useCase.fetchExercises()
                } else if let repository = repository {
                    loaded = try await repository.loadExercises()
                } else {
                    loaded = []
                }
                self.exercises = loaded
                self.state.exercises = loaded
                self.error = nil
                self.state.error = nil
            } catch {
                self.error = error as? AppError ?? .unknown("\(error)")
                self.exercises = []
                self.state.exercises = []
            }
        }
    }

    func filterByCategory(_ category: ExerciseCategory?) {
        selectedCategory = category
    }

    func selectExercise(_ exercise: Exercise) {
        selectedExercise = exercise
        state.selectedExercise = exercise
    }

    func clearError() {
        error = nil
        state.error = nil
    }

    var filteredExercises: [Exercise] {
        guard let category = selectedCategory else {
            return exercises
        }
        return exercises.filter { $0.category == category }
    }
}
