// ❌ Missing for task 2.1:
protocol CameraPreviewProviding {
    func setupPreviewLayer(in view: UIView) throws
    func updateOrientation(_ orientation: UIInterfaceOrientation)
}

// ✅ Implement:
class CameraPreviewController: CameraPreviewProviding {
    private let previewLayer = AVCaptureVideoPreviewLayer()
    
    func setupPreviewLayer(in view: UIView) throws {
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }
}