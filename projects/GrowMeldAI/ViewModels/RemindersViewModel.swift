@MainActor
final class RemindersViewModel: ObservableObject {
    // ... existing code ...
    
    deinit {
        // Ensure no leaking subscriptions
        cancellables.removeAll()
    }
}