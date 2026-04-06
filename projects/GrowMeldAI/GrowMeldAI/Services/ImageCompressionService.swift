// Services/Domain/Protocols/ImageCompressionService.swift
protocol ImageCompressionService {
  func compress(
    _ image: UIImage,
    targetSize: CGSize,
    quality: Float
  ) throws -> Data
}

// Services/Infrastructure/ImageProcessor.swift
class ImageProcessor: ImageCompressionService {
  func compress(_ image: UIImage, targetSize: CGSize, quality: Float) throws -> Data {
    guard let resized = image.resized(to: targetSize),
          let compressed = resized.jpegData(compressionQuality: CGFloat(quality))
    else { throw ImageRecognitionError.invalidImage(reason: "Compression failed") }
    return compressed
  }
}