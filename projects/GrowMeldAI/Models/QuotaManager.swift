@MainActor
final class QuotaManager: ObservableObject {
    private var autoResetTask: Task<Void, Never>?
    
    private func setupAutoReset() {
        autoResetTask?.cancel()
        
        autoResetTask = Task {
            while !Task.isCancelled {
                do {
                    let secondsUntilReset = await dateUtilities.secondsUntilMidnight()
                    
                    // Sleep with cancellation check
                    try await Task.sleep(
                        nanoseconds: UInt64(secondsUntilReset * 1_000_000_000)
                    )
                    
                    // Execute reset if still running
                    if !Task.isCancelled {
                        try await resetIfNeeded()
                    }
                } catch is CancellationError {
                    // Expected on app exit
                    print("✓ Auto-reset task cancelled")
                    break
                } catch {
                    print("⚠️ Auto-reset error: \(error)")
                    // Continue trying on next cycle
                }
            }
        }
    }
    
    deinit {
        print("Deallocating QuotaManager")
        autoResetTask?.cancel()
        // TaskGroup or async let would be more robust but Task is acceptable here
        // since @MainActor guarantees single-threaded access
    }
}