import SwiftUI
final class CameraPreviewViewController: UIViewController {
    // ...
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }
}