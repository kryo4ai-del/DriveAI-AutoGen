// ADD: Tests/Mocks/MockCameraSessionManager.swift
final class MockCameraSessionManager: CameraSessionProviding {
    @Published var shouldSucceed = true
    var isRunning: AnyPublisher<Bool, Never> { Just(true).eraseToAnyPublisher() }
    
    func startSession() async throws {
        if !shouldSucceed {
            throw CameraError.sessionStartFailed(NSError())
        }
    }
}