import Foundation
import AVFoundation

// Enum CameraError declared in Models/CameraError.swift

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