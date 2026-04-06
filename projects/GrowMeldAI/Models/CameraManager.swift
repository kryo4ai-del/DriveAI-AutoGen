import AVFoundation
import UIKit
import CoreMedia
import CoreVideo
import Combine
import Foundation

class CameraManager: NSObject {
    @Published var estimatedLuminance: Float = 0.5

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let luminance = estimateLuminance(from: pixelBuffer)

        DispatchQueue.main.async { [weak self] in
            self?.estimatedLuminance = luminance

            if luminance < 0.2 {
                UIAccessibility.post(notification: .announcement,
                    argument: "Warnung: Licht ist zu dunkel. Bitte die Beleuchtung verbessern.")
            }
        }
    }

    private func estimateLuminance(from pixelBuffer: CVPixelBuffer) -> Float {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else { return 0.5 }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)

        let buffer = baseAddress.assumingMemoryBound(to: UInt8.self)

        var totalLuminance: Int = 0
        let sampleCount = 100

        for _ in 0..<sampleCount {
            let randomRow = Int.random(in: 0..<height)
            let randomCol = Int.random(in: 0..<width)
            let offset = randomRow * bytesPerRow + randomCol * 4

            let b = Int(buffer[offset])
            let g = Int(buffer[offset + 1])
            let r = Int(buffer[offset + 2])

            let pixelLuminance = (r * 299 + g * 587 + b * 114) / 1000
            totalLuminance += pixelLuminance
        }

        return Float(totalLuminance) / Float(sampleCount * 255)
    }
}