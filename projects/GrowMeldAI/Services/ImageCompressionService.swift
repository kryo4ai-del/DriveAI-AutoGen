// Services/Domain/Protocols/ImageCompressionService.swift
import UIKit
protocol ImageCompressionService {
  func compre(
    _ image: UIImage,
    targetSize: CGSize,
    quality: Float
  ) throws -> Data
}

// Services/Infrastructure/ImageProcessor.swift
// Class ImageProcessor declared in Models/ImageProcessor.swift
