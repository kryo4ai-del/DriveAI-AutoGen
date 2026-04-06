// Services/Camera/CameraPermissionManager.swift

import AVFoundation

protocol CameraPermissionManagerProtocol {
    func requestAccess() async -> Bool
    func getCurrentStatus() -> AVAuthorizationStatus
    func isAuthorized() -> Bool
}

@MainActor