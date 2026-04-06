import Foundation
import AVFoundation

enum CameraError: LocalizedError {
    case permissionDenied
    case deviceUnavailable

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Camera permission denied."
        case .deviceUnavailable:
            return "Camera device unavailable."
        }
    }
}

final class MockCameraPermissionService {
    var shouldSucceed = true

    func requestCameraAccess() async throws -> AVAuthorizationStatus {
        try await Task.sleep(nanoseconds: 100_000_000)
        if shouldSucceed {
            return .authorized
        } else {
            throw CameraError.permissionDenied
        }
    }
}