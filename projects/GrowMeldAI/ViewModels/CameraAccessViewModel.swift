// ViewModels/CameraAccess/CameraAccessViewModel.swift

import SwiftUI
import Combine
import os.log

@MainActor
final class CameraAccessViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var showPermissionRequest = true
    @Published var hasPermission = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showRestrictedAlert = false
    @Published var showTimeoutAlert = false
    
    // MARK: - Private Properties
    
    private let cameraManager: CameraAccessManagerProtocol
    private let logger = Logger(subsystem: "com.driveai.camera", category: "CameraAccessViewModel")
    private let permissionTimeout: TimeInterval = 10 // seconds
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initialization
    
    init(cameraManager: CameraAccessManagerProtocol) {
        self.cameraManager = cameraManager
        setupInitialState()
    }
    
    // MARK: - Public Methods
    
    func checkExistingPermission() async {
        let state = await cameraManager.checkPermission()
        updateUIState(for: state)
    }
    
    func requestCameraPermission() async {
        // Prevent concurrent requests
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let state = try await withTimeout(
                timeInterval: permissionTimeout,
                operation: { await self.cameraManager.requestPermission() }
            )
            
            updateUIState(for: state)
        } catch is TimeoutError {
            handleTimeout()
        } catch {
            logger.error("Unexpected error requesting permission: \(error)")
            errorMessage = LocalizedString.cameraAccessError
        }
        
        isLoading = false
    }
    
    func skipPermission() {
        showPermissionRequest = false
        logger.debug("User skipped camera permission")
    }
    
    func openSettings() -> URL? {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return nil
        }
        
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
            logger.debug("Opened system settings")
        }
        
        return settingsURL
    }
    
    // MARK: - Private Methods
    
    private func setupInitialState() {
        Task {
            await checkExistingPermission()
        }
    }
    
    private func updateUIState(for state: PermissionState) {
        switch state {
        case .authorized:
            hasPermission = true
            showPermissionRequest = false
            errorMessage = nil
            
        case .denied:
            hasPermission = false
            errorMessage = LocalizedString.cameraAccessDenied
            logger.warning("User denied camera permission")
            
        case .restricted:
            showRestrictedAlert = true
            hasPermission = false
            logger.warning("Camera access restricted by device policy")
            
        case .notAvailable, .notDetermined:
            hasPermission = false
        }
    }
    
    private func handleTimeout() {
        showTimeoutAlert = true
        errorMessage = LocalizedString.cameraAccessTimeout
        logger.error("Camera permission request timed out")
    }
    
    // MARK: - Timeout Helper
    
    private func withTimeout<T>(
        timeInterval: TimeInterval,
        operation: @escaping () async -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            let timeoutTask = group.addTaskUnlessCancelled {
                try await Task.sleep(nanoseconds: UInt64(timeInterval * 1_000_000_000))
                throw TimeoutError()
            }
            
            let operationTask = group.addTaskUnlessCancelled {
                await operation()
            }
            
            if let result = try await group.next() {
                group.cancelAll()
                return result
            }
            
            throw TimeoutError()
        }
    }
}

// MARK: - Custom Error

// MARK: - Localization Constants

enum LocalizedString {
    static let cameraAccessDenied = String(localized: "camera_access_denied", 
                                          defaultValue: "Kamerazugriff verweigert")
    static let cameraAccessTimeout = String(localized: "camera_access_timeout", 
                                           defaultValue: "Anfrage hat zu lange gedauert")
    static let cameraAccessError = String(localized: "camera_access_error", 
                                         defaultValue: "Fehler beim Kamerazugriff")
}