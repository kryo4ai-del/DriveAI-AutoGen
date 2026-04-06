protocol CameraDelegate: AnyObject {
    func updateUI()
}

class ImageProcessor {
    var onComplete: (() -> Void)?
}

@MainActor
class CameraViewModel {
    weak var delegate: CameraDelegate?
    var imageProcessor = ImageProcessor()

    func setup() {
        imageProcessor.onComplete = { [weak self] in
            self?.delegate?.updateUI()
        }
    }
}