// ViewModels/Feedback/FeedbackLoadingState.swift
enum FeedbackLoadingState<T: Equatable>: Equatable {
    case idle
    case loading
    case success(T)
    case failure(FeedbackError)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var error: FeedbackError? {
        if case .failure(let error) = self { return error }
        return nil
    }
    
    var value: T? {
        if case .success(let value) = self { return value }
        return nil
    }
}

// ViewModels/Feedback/FeedbackCollectionViewModel.swift
@MainActor
class FeedbackCollectionViewModel {
}

// ViewModels/Feedback/FlaggedQuestionsViewModel.swift
@MainActor
class FlaggedQuestionsViewModel {
}