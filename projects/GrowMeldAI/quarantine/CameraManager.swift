import AVFoundation
import UIKit
import CoreMedia
import Combine

class CameraManager: NSObject {
    @Published var estimatedLuminance: Float = 0.5 // 0.0 = dark, 1.0 = bright
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // ✅ Measure luminance
        let luminance = estimateLuminance(from: pixelBuffer)
        
        DispatchQueue.main.async { [weak self] in
            self?.estimatedLuminance = luminance
            
            // Announce significant light changes
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
        
        var totalLuminance: UInt32 = 0
        let sampleCount = 100 // Sample subset
        
        for _ in 0..<sampleCount {
            let randomIndex = Int.random(in: 0..<(width * height))
            let offset = (randomIndex / width) * bytesPerRow + (randomIndex % width) * 4
            
            let b = UInt32(buffer[offset])
            let g = UInt32(buffer[offset + 1])
            let r = UInt32(buffer[offset + 2])
            
            // Standard luminance formula: 0.299R + 0.587G + 0.114B
            let luminance = (r * 299 + g * 587 + b * 114) / 1000
            totalLuminance += luminance
        }
        
        return Float(totalLuminance) / Float(sampleCount * 255)
    }
}