import Foundation
import AVFoundation

// MARK: - Protocol

protocol CameraPermissionServiceProtocol {
    func requestPermission() async -> Bool
    func currentStatus() -> AVAuthorizationStatus
}

// MARK: - Service

@MainActor
final class CameraPermissionService: CameraPermissionServiceProtocol {

    func requestPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    func currentStatus() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }
}