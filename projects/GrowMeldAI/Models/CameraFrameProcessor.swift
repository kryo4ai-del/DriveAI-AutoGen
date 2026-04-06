import Foundation
import CoreVideo
import CoreImage

class CameraFrameProcessor {
    private let queue = DispatchQueue(
        label: "com.driveai.frame-processing",
        qos: .userInitiated
    )

    private let ciContext = CIContext()

    func preprocessFrame(_ pixelBuffer: CVPixelBuffer) -> CVPixelBuffer {
        var result: CVPixelBuffer = pixelBuffer
        queue.sync {
            let resized = self.resize(pixelBuffer, to: CGSize(width: 640, height: 640))
            result = resized
        }
        return result
    }

    private func resize(_ pixelBuffer: CVPixelBuffer, to size: CGSize) -> CVPixelBuffer {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let scaleX = size.width / CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let scaleY = size.height / CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        let scaled = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        var outputBuffer: CVPixelBuffer?
        let attrs: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(size.width),
            Int(size.height),
            CVPixelBufferGetPixelFormatType(pixelBuffer),
            attrs as CFDictionary,
            &outputBuffer
        )
        guard status == kCVReturnSuccess, let output = outputBuffer else {
            return pixelBuffer
        }
        ciContext.render(scaled, to: output)
        return output
    }
}