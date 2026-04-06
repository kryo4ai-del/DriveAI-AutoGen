// Infrastructure/Camera/CameraFrameProcessor.swift
class CameraFrameProcessor {
    private let queue = DispatchQueue(
        label: "com.driveai.frame-processing",
        qos: .userInitiated
    )
    
    func preprocessFrame(_ pixelBuffer: CVPixelBuffer) -> CVPixelBuffer {
        var outputBuffer: CVPixelBuffer?
        
        queue.async {
            // Target: <100ms for resize + normalize
            let resized = self.resize(pixelBuffer, to: CGSize(width: 640, height: 640))
            let normalized = self.normalize(resized)
            outputBuffer = normalized
        }
        
        return outputBuffer ?? pixelBuffer
    }
}