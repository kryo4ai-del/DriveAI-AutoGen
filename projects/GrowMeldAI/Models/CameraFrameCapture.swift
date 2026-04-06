import Foundation
import AVFoundation
import Combine

enum CameraError: Error, LocalizedError {
    case captureFailed(Error)

    var errorDescription: String? {
        switch self {
        case .captureFailed(let error):
            return "Camera capture failed: \(error.localizedDescription)"
        }
    }
}

protocol CameraFrameCaptureDelegate: AnyObject {
    func didFailWithError(_ error: CameraError)
}

final class CameraFrameCapture: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let frameSubject = PassthroughSubject<CVPixelBuffer?, Never>()
    private let frameQueue = DispatchQueue(label: "com.driveai.frame.process", qos: .userInitiated)
    private var isProcessing = false

    weak var delegate: CameraFrameCaptureDelegate?

    var framePublisher: AnyPublisher<CVPixelBuffer?, Never> {
        frameSubject.eraseToAnyPublisher()
    }

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard CMSampleBufferGetNumSamples(sampleBuffer) > 0 else { return }

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        guard !isProcessing else {
            delegate?.didFailWithError(CameraError.captureFailed(
                NSError(domain: "Frame", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Frame dropped – processing backed up"
                ])
            ))
            return
        }

        frameQueue.async { [weak self] in
            self?.isProcessing = true
            defer { self?.isProcessing = false }
            self?.frameSubject.send(pixelBuffer)
        }
    }
}