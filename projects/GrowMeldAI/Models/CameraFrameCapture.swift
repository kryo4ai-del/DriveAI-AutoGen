import Foundation
import AVFoundation
import Combine

// Enum CameraError declared in Models/CameraError.swift

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
            delegate?.didFailWithError(CameraError.captureFailed)
            return
        }

        frameQueue.async { [weak self] in
            self?.isProcessing = true
            defer { self?.isProcessing = false }
            self?.frameSubject.send(pixelBuffer)
        }
    }
}