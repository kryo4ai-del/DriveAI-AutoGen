// ViewModels/QuestionViewModel.swift (EXISTING - DO NOT REFACTOR)
extension QuestionViewModel {
    func fetchQuestions(
        category: QuestionCategory,
        locationFilter: PLZRegion? = nil  // NEW PARAMETER
    ) async {
        let questions = await dataService.fetchQuestions(
            category: category,
            bundesland: locationFilter?.id  // Pass to service
        )
        // Existing logic unchanged
    }
}

// Services/LocalDataService.swift (EXISTING - MINIMAL CHANGES)
extension LocalDataService {
    func fetchQuestions(
        category: QuestionCategory,
        bundesland: String? = nil  // NEW OPTIONAL FILTER
    ) async -> [Question] {
        if let bundesland = bundesland {
            // SELECT * WHERE category = ? AND bundesland = ?
        } else {
            // SELECT * WHERE category = ? (existing behavior)
        }
    }
}