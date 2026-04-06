// Services/CameraPermissionStateRefresher.swift
@MainActor
final class CameraPermissionStateRefresher {
    private let cameraManager: CameraAccessManager
    private var scenePhaseSubscription: AnyCancellable?
    
    var onStatusChanged: ((CameraPermissionState) -> Void)?
    
    init(cameraManager: CameraAccessManager) {
        self.cameraManager = cameraManager
        observeAppEvents()
    }
    
    func checkAndRefresh() -> CameraPermissionState {
        let status = cameraManager.checkCameraPermission()
        return CameraPermissionState(status)
    }
    
    private func observeAppEvents() {
        scenePhaseSubscription = NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                let newStatus = self?.checkAndRefresh()
                self?.onStatusChanged?(newStatus ?? .unavailable)
            }
    }
    
    deinit {
        scenePhaseSubscription?.cancel()
    }
}

// ViewModel usage:
@MainActor