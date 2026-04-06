import Foundation
import Combine

protocol CameraSessionProviding {
    var isRunning: AnyPublisher<Bool, Never> { get }
    func startSession() async throws
}

enum CameraError: Error {
    case sessionStartFailed
}

final class MockCameraSessionManager: CameraSessionProviding {
    var shouldSucceed = true
    var isRunning: AnyPublisher<Bool, Never> { Just(true).eraseToAnyPublisher() }

    func startSession() async throws {
        if !shouldSucceed {
            throw CameraError.sessionStartFailed
        }
    }
}