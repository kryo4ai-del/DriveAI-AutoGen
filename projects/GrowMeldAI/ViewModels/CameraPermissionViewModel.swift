// ViewModels/CameraPermissionViewModel.swift
import Foundation

@MainActor
final class CameraPermissionViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showSettings = false
    
    private let coordinator: CameraCoordinator
    
    init(coordinator: CameraCoordinator) {
        self.coordinator = coordinator
    }
    
    func requestPermission() async {
        isLoading = true
        defer { isLoading = false }
        
        await coordinator.requestPermissionAndInitialize()
        
        if coordinator.state.permissionStatus == .denied {
            showSettings = true
        }
    }
    
    func openSettings() {
        coordinator.permissionService.openAppSettings()
    }
}