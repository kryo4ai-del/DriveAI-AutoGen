func recordAnswer(
    questionId: UUID,
    categoryId: UUID,
    selectedIndex: Int,
    correctIndex: Int
) async throws {
    // Validate inputs
    guard selectedIndex >= 0 && selectedIndex < 4 else {
        throw ProgressError.invalidAnswerIndex
    }
    
    // Create backup before mutation
    let backup = userProgress
    
    do {
        let isCorrect = selectedIndex == correctIndex
        
        // Ensure category exists
        if userProgress.categories.first(where: { $0.categoryId == categoryId }) == nil {
            userProgress.categories.append(CategoryProgress(categoryId: categoryId))
        }
        
        // Update stats (isolated mutation)
        updateCategoryStats(categoryId: categoryId, isCorrect: isCorrect)
        updateGlobalStats(isCorrect: isCorrect)
        
        // Persist atomically
        try await persistenceService.saveUserProgress(userProgress)
    } catch {
        // Rollback on failure
        self.userProgress = backup
        throw ProgressError.persistenceFailed(error)
    }
}

private func updateCategoryStats(categoryId: UUID, isCorrect: Bool) {
    guard let index = userProgress.categories.firstIndex(where: { $0.categoryId == categoryId }) else {
        return
    }
    
    var category = userProgress.categories[index]
    category.questionsAnswered += 1
    if isCorrect {
        category.correctAnswers += 1
    }
    
    let nextReview = spacedRepetitionCalculator.calculateNextReviewDate(
        reviewCount: category.reviewCount,
        accuracy: category.accuracy
    )
    category.nextReviewDate = nextReview
    category.reviewCount += 1
    category.lastReviewDate = Date()
    
    userProgress.categories[index] = category
}

private func updateGlobalStats(isCorrect: Bool) {
    userProgress.totalQuestionsAnswered += 1
    if isCorrect {
        userProgress.totalCorrectAnswers += 1
        userProgress.currentStreak += 1
        userProgress.longestStreak = max(userProgress.currentStreak, userProgress.longestStreak)
    } else {
        userProgress.currentStreak = 0
    }
    userProgress.lastReviewDate = Date()
}

enum ProgressError: LocalizedError {
    case invalidAnswerIndex
    case persistenceFailed(Error)
    case categoryNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidAnswerIndex:
            return NSLocalizedString("Ungültige Antwortindex", comment: "")
        case .persistenceFailed(let error):
            return "Fehler beim Speichern: \(error.localizedDescription)"
        case .categoryNotFound:
            return NSLocalizedString("Kategorie nicht gefunden", comment: "")
        }
    }
}