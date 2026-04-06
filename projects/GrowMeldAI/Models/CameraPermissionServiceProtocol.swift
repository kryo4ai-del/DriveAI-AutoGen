import Foundation
import AVFoundation
import UIKit

// MARK: - Camera Permission Status
enum CameraPermissionStatus2 {
    case authorized
    case denied
    case restricted
    case notDetermined
}

// MARK: - Camera Permission Service Protocol
protocol CameraPermissionServiceProtocol: Sendable {
    func requestCameraAccess() async throws -> CameraPermissionStatus2
    func checkCurrentPermissionStatus() -> CameraPermissionStatus2
    func openAppSettings() async
}

// MARK: - Camera Permission Service Implementation
@MainActor
final class CameraPermissionService: CameraPermissionServiceProtocol {
    func requestCameraAccess() async throws -> CameraPermissionStatus2 {
        let granted = await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { result in
                continuation.resume(returning: result)
            }
        }
        return granted ? .authorized : .denied
    }

    func checkCurrentPermissionStatus() -> CameraPermissionStatus2 {
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