@MainActor
final class FlaggedQuestionsViewModel: ObservableObject {
    @Published var flaggedQuestions: [Question] = []
    @Published var readyForReviewCount: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var loadTask: Task<Void, Never>?
    
    func loadFlaggedQuestions() async {
        // ✅ Cancel previous load
        loadTask?.cancel()
        loadTask = nil
        
        isLoading = true
        errorMessage = nil
        
        loadTask = Task {
            defer {
                // ✅ Only set false AFTER async work completes
                if !Task.isCancelled {
                    self.isLoading = false
                }
            }
            
            do {
                let allQuestions = try await questionsService.getAllQuestions()
                
                // ✅ Check cancellation before state update
                if !Task.isCancelled {
                    self.flaggedQuestions = allQuestions.filter { $0.hasFeedback }
                    self.readyForReviewCount = allQuestions
                        .filter { $0.hasFeedback && $0.isReadyForReview }
                        .count
                }
            } catch is CancellationError {
                // Task was cancelled, expected
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    deinit {
        loadTask?.cancel()
    }
}

// In View:
.onAppear {
    Task {
        await viewModel.loadFlaggedQuestions()
    }
}
// ✅ Only runs once per view appearance