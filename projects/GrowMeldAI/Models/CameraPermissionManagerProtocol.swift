// Services/Camera/CameraPermissionManager.swift

import AVFoundation

protocol CameraPermissionManagerProtocol {
    func requestAccess() async -> Bool
    func getCurrentStatus() -> AVAuthorizationStatus
    func isAuthorized() -> Bool
}

@MainActor
class CameraPermissionManager: CameraPermissionManagerProtocol {
    func requestAccess() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }

    func getCurrentStatus() -> AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }

    func isAuthorized() -> Bool {
        getCurrentStatus() == .authorized
    }
}