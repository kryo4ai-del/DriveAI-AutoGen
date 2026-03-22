enum QuickAccessError: LocalizedError {
    case userNotAuthenticated
    case noExercisesAvailable
    case exerciseNotFound(String)
    case invalidNavigationPath(String)
    case serviceFailure(String)
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "Please log in to access quizzes"
        case .noExercisesAvailable:
            return "No exercises available in your current plan"
        case .exerciseNotFound(let id):
            return "Exercise \(id) not found"
        default:
            return "Something went wrong"
        }
    }
}