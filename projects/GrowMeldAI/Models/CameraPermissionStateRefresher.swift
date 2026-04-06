// Services/CameraPermissionStateRefresher.swift
import UIKit
import Combine

enum CameraPermissionState {
    case authorized
    case denied
    case notDetermined
    case unavailable
    
    init(_ status: Int) {
        switch status {
        case 0: self = .notDetermined
        case 1: self = .denied
        case 2: self = .authorized
        default: self = .unavailable
        }
    }
}

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