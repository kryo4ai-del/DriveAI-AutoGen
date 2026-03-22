// In DefaultQuickAccessService
let availableExercises = try await exerciseSelectionService.fetchAvailableExercises()
let todaysChallenge = try await exerciseSelectionService.fetchTodaysChallenge()

// ---

// In DefaultQuickAccessService
let lastIncomplete = try await quizProgressService.fetchLastIncompleteExercise()
let weakAreas = try await quizProgressService.fetchWeakAreas(limit: 3)
let categoryScores = try await quizProgressService.fetchCategoryScores()

// ---

// In QuickAccessCoordinator
self.navigationPath = .resumeLastQuiz(exerciseID: lastExercise.id)
// SwiftUI observes @Published navigationPath and triggers navigation

// ---

let recommendations = try await recommendationService.fetchSmartSuggestions()
navigationPath = .recommendedExercise(recommendations.first!)

// ---

if featureFlags.isQuickAccessMenuEnabled {
    showMenu()
} else {
    directLaunch()
}