// ✅ FIXED
enum QuestionTransitionError: Error {
    case invalidState(current: QuestionViewState, expected: String)
    case outOfBounds
}

@MainActor
func selectAnswer(_ answerIndex: Int) async throws {
    guard case .loaded(let question) = state else {
        throw QuestionTransitionError.invalidState(
            current: state, 
            expected: "loaded"
        )
    }
    
    guard (0..<question.options.count).contains(answerIndex) else {
        throw QuestionTransitionError.invalidState(
            current: state,
            expected: "valid answer index"
        )
    }
    
    let isCorrect = answerIndex == question.correctAnswerIndex
    
    // Persist answer before changing state
    do {
        try await dataService.saveAnswer(
            questionId: question.id,
            isCorrect: isCorrect,
            timestamp: Date()
        )
    } catch {
        self.error = AppError.databaseError("Failed to save answer: \(error)")
        return
    }
    
    state = .showingFeedback(isCorrect: isCorrect, explanation: question.explanation)
}

@MainActor
func nextQuestion() throws {
    guard case .showingFeedback = state else {
        throw QuestionTransitionError.invalidState(
            current: state,
            expected: "showingFeedback"
        )
    }
    
    currentIndex += 1
    
    guard currentIndex < questions.count else {
        let finalScore = calculateScore()
        state = .completed(score: finalScore)
        
        // Persist exam session
        Task {
            try? await saveExamSession(finalScore)
        }
        return
    }
    
    state = .loaded(questions[currentIndex])
}

// Prevent double-tap by disabling button during transition
var isTransitionInProgress: Bool {
    if case .showingFeedback = state { return true }
    return isLoading
}