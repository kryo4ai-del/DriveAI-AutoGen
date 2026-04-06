@MainActor
final class FeedbackCollectionViewModel: ObservableObject {
    @Published var confirmationMessage: String?
    private var confirmationTask: Task<Void, Never>?
    private var isActive = true
    
    nonisolated func submitFeedback() async {
        await MainActor.run {
            guard isActive else { return }
            // Perform work
        }
        
        // ✅ Cancel any pending task
        confirmationTask?.cancel()
        
        confirmationTask = Task {
            try await Task.sleep(nanoseconds: 2_000_000_000)
            
            // ✅ Only update if ViewModel still exists
            if !Task.isCancelled {
                await MainActor.run {
                    guard self.isActive else { return }
                    withAnimation {
                        self.confirmationMessage = nil
                    }
                }
            }
        }
    }
    
    deinit {
        isActive = false
        confirmationTask?.cancel()
    }
}