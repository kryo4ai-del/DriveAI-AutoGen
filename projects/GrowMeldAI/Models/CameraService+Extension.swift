import AVFoundation
import Combine

enum CameraState {
    case idle
    case processing
}

class CameraService: NSObject, ObservableObject {
    @Published var state: CameraState = .idle

    private func processPhoto(data: Data) async {
        await MainActor.run {
            self.state = .processing
        }
    }
}

extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        DispatchQueue.main.async {
            self.state = .idle
        }
    }
}