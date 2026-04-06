import Foundation
import SwiftUI
import Combine
import os

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
    private let logger = OSLog(subsystem: "com.driveai.camera", category: "CameraAccessViewModel")
    private let permissionTimeout: TimeInterval = 10
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
            os_log("Unexpected error requesting permission: %@", log: logger, type: .error, error.localizedDescription)
            errorMessage = LocalizedString.cameraAccessError
        }

        isLoading = false
    }

    func skipPermission() {
        showPermissionRequest = false
        os_log("User skipped camera permission", log: logger, type: .debug)
    }

    func openSettings() -> URL? {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return nil
        }

        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
            os_log("Opened system settings", log: logger, type: .debug)
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
        case .granted:
            hasPermission = true
            showPermissionRequest = false
            errorMessage = nil

        case .denied:
            hasPermission = false
            errorMessage = LocalizedString.cameraAccessDenied
            os_log("User denied camera permission", log: logger, type: .default)

        case .restricted:
            showRestrictedAlert = true
            hasPermission = false
            os_log("Camera access restricted by device policy", log: logger, type: .default)

        case .undetermined:
            hasPermission = false
        }
    }

    private func handleTimeout() {
        showTimeoutAlert = true
        errorMessage = LocalizedString.cameraAccessTimeout
        os_log("Camera permission request timed out", log: logger, type: .error)
    }

    // MARK: - Timeout Helper

    private func withTimeout<T>(
        timeInterval: TimeInterval,
        operation: @escaping () async -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await Task.sleep(nanoseconds: Swift.UInt64(timeInterval * 1_000_000_000))
                throw TimeoutError()
            }

            group.addTask {
                await operation()
            }

            guard let result = try await group.next() else {
                group.cancelAll()
                throw TimeoutError()
            }

            group.cancelAll()
            return result
        }
    }
}

// MARK: - Supporting Types

struct TimeoutError: Error {}

enum PermissionState {
    case granted
    case denied
    case restricted
    case undetermined
}

protocol CameraAccessManagerProtocol {
    func checkPermission() async -> PermissionState
    func requestPermission() async -> PermissionState
}

enum LocalizedString {
    static let cameraAccessError = "Ein Fehler ist aufgetreten. Bitte versuche es erneut."
    static let cameraAccessDenied = "Kamerazugriff wurde verweigert. Bitte aktiviere ihn in den Einstellungen."
    static let cameraAccessTimeout = "Die Anfrage hat zu lange gedauert. Bitte versuche es erneut."
}