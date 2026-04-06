// ✅ CORRECT
import Combine
@MainActor
final class CameraCoordinator: ObservableObject {
    // ... existing code ...
    
    deinit {
        // cleanup()  // Ensures camera released
    }
}