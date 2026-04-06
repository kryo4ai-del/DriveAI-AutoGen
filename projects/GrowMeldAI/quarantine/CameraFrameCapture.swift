final class CameraFrameCapture: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let frameSubject = PassthroughSubject<CVPixelBuffer?, Never>()
    private let frameQueue = DispatchQueue(label: "com.driveai.frame.process", qos: .userInitiated)
    private var isProcessing = false
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard CMSampleBufferGetNumSamples(sampleBuffer) > 0 else { return }
        
        // Extract pixel buffer (lighter weight than full sample buffer)
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // Drop frame if processing is backed up
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
            
            // Work with pixel buffer (lifetime managed by delegate)
            self?.frameSubject.send(pixelBuffer)
        }
    }
}