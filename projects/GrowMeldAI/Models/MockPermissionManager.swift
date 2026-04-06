final class MockPermissionManager: PermissionManagerProtocol {
    var requestedPermissionCount = 0
    var permissionStateToReturn: CameraPermissionState = .authorized
    
    func requestCameraPermission() async -> CameraPermissionState {
        requestedPermissionCount += 1
        try? await Task.sleep(nanoseconds: 100_000_000) // Simulate delay
        return permissionStateToReturn
    }
    
    func getCurrentPermissionStatus() -> CameraPermissionState {
        return permissionStateToReturn
    }
    
    func openAppSettings() {
        // No-op in tests
    }
}