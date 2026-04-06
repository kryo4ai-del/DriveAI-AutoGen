import AVFoundation
import UIKit

final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    typealias PhotoHandler = (UIImage) -> Void
    typealias ErrorHandler = (Error) -> Void
    
    private let photoHandler: PhotoHandler
    private let errorHandler: ErrorHandler
    
    init(photoHandler: @escaping PhotoHandler, errorHandler: @escaping ErrorHandler) {
        self.photoHandler = photoHandler
        self.errorHandler = errorHandler
    }
    
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error {
            errorHandler(error)
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            errorHandler(CameraError.sessionNotReady)
            return
        }
        
        let correctedImage = image.withFixedOrientation()
        photoHandler(correctedImage)
    }
}

extension UIImage {
    func withFixedOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        
        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -CGFloat.pi / 2)
        case .upMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        @unknown default:
            return self
        }
        
        guard let cgImage = cgImage else { return self }
        let ctx = CIContext()
        
        if let ciImage = CIImage(cgImage: cgImage) {
            let transformed = ciImage.transformed(by: transform)
            if let result = ctx.createCGImage(transformed, from: transformed.extent) {
                return UIImage(cgImage: result, scale: scale, orientation: .up)
            }
        }
        
        return self
    }
}