import Foundation

// PREFER: Protocol-based weak references
protocol CameraDelegate: AnyObject {
    func cameraDidFinish()
}

// PREFER: Weak capture in ViewModels
@MainActor
class CameraViewModel {
    weak var delegate: CameraDelegate?

    var imageProcessor: ImageProcessor?

    func processImage() {
        imageProcessor?.onComplete = { [weak self] in
            self?.updateUI()
        }
    }

    func updateUI() {
        // Update UI
    }
}

class ImageProcessor {
    var onComplete: (() -> Void)?
}