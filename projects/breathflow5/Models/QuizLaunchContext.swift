import Foundation

// MARK: - Supporting Types

enum ExerciseCategory {
    case vocabulary
    case grammar
    case reading
    case listening
    case speaking
    case writing
    case custom(String)
}

enum QuizMode {
    case review
    case practice
    case challenge
}

enum AuthState {
    case authenticated
    case unauthenticated
    case pending
}

// MARK: - AccessPoint

/// Where the user initiated the quick access
enum AccessPoint {
    case homeScreenButton
    case notificationTap
    case deepLink(url: URL)
    case smartSuggestion
    case appShortcut
}

// MARK: - QuizLaunchContext

/// Represents the state needed to launch a quiz
struct QuizLaunchContext {
    let exerciseID: String
    let category: ExerciseCategory
    let mode: QuizMode  // review, practice, challenge
    let sourceAccessPoint: AccessPoint
    let userAuthState: AuthState
}

// MARK: - NavigationPath

/// Represents a navigation action from quick access
enum NavigationPath {
    case resumeLastQuiz
    case quickReviewWeakAreas
    case practiceTodaysChallenge
    case reviewCategory(ExerciseCategory)
    case custom(exerciseID: String, mode: QuizMode)
}