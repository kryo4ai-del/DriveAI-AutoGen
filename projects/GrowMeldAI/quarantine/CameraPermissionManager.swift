// Infrastructure/Camera/CameraPermissionManager.swift
class CameraPermissionManager: NSObject, ObservableObject {
    @Published var status: AVAuthorizationStatus
    
    override init() {
        status = AVCaptureDevice.authorizationStatus(for: .video)
        super.init()
    }
    
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.status = AVCaptureDevice.authorizationStatus(for: .video)
            }
        }
    }
}