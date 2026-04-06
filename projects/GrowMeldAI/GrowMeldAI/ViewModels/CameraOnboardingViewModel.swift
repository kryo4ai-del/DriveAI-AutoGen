// Features/CameraOnboarding/Presentation/ViewModels/CameraOnboardingViewModel.swift
import Foundation
import SwiftUI

@MainActor
final class CameraOnboardingViewModel: ObservableObject {
    @Published var currentState: LicenseCaptureState = .initial
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var progress: Double = 0.0

    private let repository: LicenseCaptureRepository

    init(repository: LicenseCaptureRepository) {
        self.repository = repository
    }

    // MARK: - Flow Methods
    func requestPermission() async {
        do {
            let decision = try await repository.requestCameraPermission()
            currentState = decision.isGranted ? .capturing : .permissionNeeded
            updateProgress(for: decision.isGranted ? .capturing : .permissionNeeded)
        } catch {
            errorMessage = "Kamera-Berechtigung erforderlich"
            currentState = .error(.permissionDenied)
        }
    }

    func captureImage(_ image: UIImage) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let capturedImage = try await repository.processAndStoreLicense(image)
            currentState = .confirmed(capturedImage)
            updateProgress(for: .confirmed(capturedImage))
        } catch {
            errorMessage = error.localizedDescription
            currentState = .error(error as? LicenseCaptureError ?? .unknown)
        }
    }

    func retryPermissionRequest() async {
        currentState = .initial
        errorMessage = nil
        progress = 0.0
    }

    private func updateProgress(for state: LicenseCaptureState) {
        switch state {
        case .initial:
            progress = 0.0
        case .permissionNeeded:
            progress = 0.33
        case .capturing:
            progress = 0.66
        case .preview, .confirmed:
            progress = 1.0
        case .error:
            progress = 0.0
        }
    }
}