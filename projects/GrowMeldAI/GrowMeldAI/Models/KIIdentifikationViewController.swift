// ✅ PROPER ASYNC/AWAIT PATTERN
@MainActor
final class KIIdentifikationViewController: UIViewController {
    // All UI updates happen on MainActor
    
    func handleResponse(answerId: String) {
        Task {
            // UI state update (on main thread)
            viewModel.identificationState = .processing
            
            // Background work
            let result = await viewModel.recordIdentification(answerId: answerId)
            
            // Back to main thread automatically
            updateUI(with: result)
        }
    }
}