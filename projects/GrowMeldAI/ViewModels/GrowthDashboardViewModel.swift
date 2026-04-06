@MainActor
final class GrowthDashboardViewModel: ObservableObject {
    private var loadTask: Task<Void, Never>?
    
    func loadDashboard() async {
        // Cancel any existing load
        loadTask?.cancel()
        
        loadTask = Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let patterns = try await dataService.fetchAllWeaknesses()
                
                // Guard: Task wasn't cancelled while awaiting
                guard !Task.isCancelled else { return }
                
                self.weaknesses = patterns.sorted { 
                    $0.recommendedFocusLevel.rawValue < $1.recommendedFocusLevel.rawValue 
                }
                self.isLoading = false
            } catch is CancellationError {
                // Expected—don't update state
                return
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func cancelLoad() {
        loadTask?.cancel()
    }
}

// In View:
.task {
    await viewModel.loadDashboard()
    return {
        viewModel.cancelLoad()
    }
}