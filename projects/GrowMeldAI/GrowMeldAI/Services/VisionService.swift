// VisionService.swift
import Foundation
import CoreML
import Vision
import UIKit

final class VisionService: VisionServiceProtocol {
    private let targetSize = CGSize(width: 224, height: 224)
    private let context = CIContext()

    func preprocessImage(_ image: UIImage) async throws -> CVPixelBuffer {
        // Validate input
        guard let cgImage = image.cgImage else {
            throw RecognitionError.imageCaptureFailed
        }

        // Correct orientation
        let correctedImage = image.oriented(.up)

        // Crop to square
        let squareImage = cropToSquare(correctedImage)

        // Resize to target dimensions
        let resizedImage = resize(squareImage, to: targetSize)

        // Convert to CVPixelBuffer
        guard let pixelBuffer = convertToCVPixelBuffer(resizedImage) else {
            throw RecognitionError.preprocessingFailed
        }

        // Normalize pixel buffer
        normalize(pixelBuffer)

        return pixelBuffer
    }

    func extractQRMetadata(_ image: UIImage) async throws -> String? {
        guard let cgImage = image.cgImage else { return nil }

        let request = VNDetectBarcodesRequest()
        request.symbologies = [.qr]

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])

        guard let results = request.results?.first as? VNBarcodeObservation else {
            return nil
        }

        return results.payloadStringValue
    }

    // MARK: - Private Methods

    private func cropToSquare(_ image: UIImage) -> UIImage {
        let size = min(image.size.width, image.size.height)
        let x = (image.size.width - size) / 2
        let y = (image.size.height - size) / 2
        let rect = CGRect(x: x, y: y, width: size, height: size)

        return image.cropped(to: rect)
    }

    private func resize(_ image: UIImage, to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    private func normalize(_ pixelBuffer: CVPixelBuffer) {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)

        guard let data = CVPixelBufferGetBaseAddress(pixelBuffer) else { return }

        // Normalize pixel values to [0, 1] range
        let floatData = data.bindMemory(to: Float.self, capacity: width * height * 4)

        for i in 0..<(width * height) {
            floatData[i * 4] = floatData[i * 4] / 255.0 // R
            floatData[i * 4 + 1] = floatData[i * 4 + 1] / 255.0 // G
            floatData[i * 4 + 2] = floatData[i * 4 + 2] / 255.0 // B
            // Alpha channel remains unchanged
        }
    }

    private func convertToCVPixelBuffer(_ image: UIImage) -> CVPixelBuffer? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(targetSize.width),
            Int(targetSize.height),
            kCVPixelFormatType_32ARGB,
            attrs,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        let pixelData = CVPixelBufferGetBaseAddress(buffer)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: pixelData,
            width: Int(targetSize.width),
            height: Int(targetSize.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )

        context?.translateBy(x: 0, y: targetSize.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.draw(image.cgImage!, in: CGRect(origin: .zero, size: targetSize))

        CVPixelBufferUnlockBaseAddress(buffer, [])
        return buffer
    }
}

// MARK: - UIImage Extension

private extension UIImage {
    func cropped(to rect: CGRect) -> UIImage {
        guard let cgImage = cgImage?.cropping(to: rect) else { return self }
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }

    func oriented(_ orientation: UIImage.Orientation) -> UIImage {
        if self.imageOrientation == orientation {
            return self
        }

        return UIGraphicsImageRenderer(size: size).image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}