// MARK: - VisionService: Image preprocessing
import Vision
import CoreML

protocol VisionServiceProtocol {
    func preprocessImage(_ image: UIImage) -> CVPixelBuffer?
    func extractQRMetadata(_ image: UIImage) -> String?
}

@MainActor
class VisionService: VisionServiceProtocol {
    
    private let targetSize = CGSize(width: 224, height: 224)
    
    func preprocessImage(_ image: UIImage) -> CVPixelBuffer? {
        // 1. Fix orientation
        let correctedImage = image.oriented(.up)
        
        // 2. Resize to model input size
        guard let resized = resizeImage(correctedImage, to: targetSize) else {
            return nil
        }
        
        // 3. Convert to CVPixelBuffer
        guard let pixelBuffer = convertToCVPixelBuffer(resized) else {
            return nil
        }
        
        return pixelBuffer
    }
    
    func extractQRMetadata(_ image: UIImage) -> String? {
        guard let cgImage = image.cgImage else { return nil }
        
        let request = VNDetectBarcodesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        try? handler.perform([request])
        
        return request.results?
            .compactMap { $0 as? VNBarcodeObservation }
            .first?
            .payloadStringValue
    }
    
    // MARK: - Private Helpers
    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    private func convertToCVPixelBuffer(_ image: UIImage) -> CVPixelBuffer? {
        guard let cgImage = image.cgImage else { return nil }
        
        var pixelBuffer: CVPixelBuffer?
        let attrs: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            cgImage.width,
            cgImage.height,
            kCVPixelFormatType_32BGRA,
            attrs as CFDictionary,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, .readAndWrite)
        defer { CVPixelBufferUnlockBaseAddress(buffer, .readAndWrite) }
        
        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: cgImage.width,
            height: cgImage.height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        ) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        return buffer
    }
}