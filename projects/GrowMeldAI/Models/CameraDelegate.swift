import Foundation

protocol CameraDelegate: AnyObject {
    func cameraDidFinish()
}

@MainActor
class CameraViewModel_Camera {
    weak var delegate: CameraDelegate?

    var imageProcessor: ImageProcessor_Camera?

    func processImage() {
        imageProcessor?.onComplete = { [weak self] in
            self?.updateUI()
        }
    }

    func updateUI() {}
}

class ImageProcessor_Camera {
    var onComplete: (() -> Void)?
}