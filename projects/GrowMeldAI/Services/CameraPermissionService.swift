import Foundation
import AVFoundation

class CameraPermissionService2 {
    func checkStatus() -> AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }
}
