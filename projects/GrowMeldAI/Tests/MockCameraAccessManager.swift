// Features/Camera/Mocks/MockCameraAccessManager.swift
@MainActor
final class MockCameraAccessManager: CameraAccessManager {
    var mockStatus: CameraPermissionStatus = .notDetermined
    var requestPermissionCalled = false
    var openSettingsCalled = false
    
    func checkCameraPermission() -> CameraPermissionStatus {
        mockStatus
    }
    
    func requestCameraPermission() async -> CameraPermissionStatus {
        requestPermissionCalled = true
        return mockStatus
    }
    
    func openAppSettings() {
        openSettingsCalled = true
    }
}