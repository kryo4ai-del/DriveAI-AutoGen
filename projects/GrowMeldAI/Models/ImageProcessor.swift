// Services/Infrastructure/ImageProcessor.swift
import Foundation
import UIKit

class ImageProcessor: ImageCompressionService {
    func compress(_ image: UIImage, targetSize: CGSize, quality: Float) throws -> Data {
        guard let resized = image.resized(to: targetSize) else {
            throw ImageRecognitionError.invalidImage(reason: "Failed to resize image")
        }
        guard let compressed = resized.jpegData(compressionQuality: CGFloat(quality)) else {
            throw ImageRecognitionError.invalidImage(reason: "Failed to compress image")
        }
        return compressed
    }
}

private extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}