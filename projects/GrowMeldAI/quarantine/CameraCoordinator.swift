import SwiftUI
import AVFoundation

@MainActor
final class CameraCoordinator: ObservableObject {
    @Published var isSessionRunning: Bool = false
    @Published var capturedImage: UIImage? = nil
    @Published var error: Error? = nil

    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?

    init() {}

    func startSession() {
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)

        let output = AVCapturePhotoOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            photoOutput = output
        }

        session.commitConfiguration()
        captureSession = session

        Task.detached {
            session.startRunning()
            await MainActor.run {
                self.isSessionRunning = session.isRunning
            }
        }
    }

    func stopSession() {
        captureSession?.stopRunning()
        isSessionRunning = false
    }

    func cleanup() {
        stopSession()
        captureSession = nil
        photoOutput = nil
        capturedImage = nil
        error = nil
    }

    deinit {
        cleanup()
    }
}