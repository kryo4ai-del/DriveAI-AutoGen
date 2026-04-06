import Foundation
import AVFoundation

final class CameraPreviewService {
    func createPreviewLayer(session: AVCaptureSession) -> AVCaptureVideoPreviewLayer {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        return layer
    }
}