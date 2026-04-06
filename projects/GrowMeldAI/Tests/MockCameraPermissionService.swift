// Tests/Mocks/MockCameraPermissionService.swift
final class MockCameraPermissionService: CameraPermissionService {
    var shouldSucceed = true
    
    override func requestCameraAccess() async throws -> AVAuthorizationStatus {
        try await Task.sleep(nanoseconds: 100_000_000) // Simulate delay
        if shouldSucceed {
            return .authorized
        } else {
            throw CameraError.permissionDenied
        }
    }
}