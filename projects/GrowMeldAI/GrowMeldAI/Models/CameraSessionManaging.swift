// ❌ Hard to test:
let manager = CameraSessionManager() // No way to mock in ViewModel

// ✅ Fix with protocol:
protocol CameraSessionManaging {
    var isRunning: AnyPublisher<Bool, Never> { get }
    func startSession() async throws
}
