import Foundation
import AVFoundation
import UIKit

// MARK: - Camera Permission Status
enum CameraPermissionStatus {
    case authorized
    case denied
    case restricted
    case notDetermined
}

// MARK: - Camera Permission Service Protocol
protocol CameraPermissionServiceProtocol: Sendable {
    func requestCameraAccess() async throws -> CameraPermissionStatus
    func checkCurrentPermissionStatus() -> CameraPermissionStatus
    func openAppSettings() async
}

// MARK: - Camera Permission Service Implementation
@MainActor
final class CameraPermissionService: CameraPermissionServiceProtocol {
    func requestCameraAccess() async throws -> CameraPermissionStatus {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        return granted ? .authorized : .denied
    }

    func checkCurrentPermissionStatus() -> CameraPermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .denied
        }
    }

    func openAppSettings() async {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        await UIApplication.shared.open(url)
    }
}