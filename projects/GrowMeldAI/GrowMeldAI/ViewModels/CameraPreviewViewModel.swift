// ViewModels/CameraPreviewViewModel.swift
import SwiftUI

@MainActor
final class CameraPreviewViewModel: ObservableObject {
    @Published var isCapturing = false
    
    private let coordinator: CameraCoordinator
    
    init(coordinator: CameraCoordinator) {
        self.coordinator = coordinator
    }
    
    var cameraState: CameraState { coordinator.state }
    var isReady: Bool { coordinator.state.isReady }
    
    func capturePhoto() async -> UIImage? {
        isCapturing = true
        defer { isCapturing = false }
        return await coordinator.capturePhoto()
    }
    
    func cleanup() {
        coordinator.cleanup()
    }
}