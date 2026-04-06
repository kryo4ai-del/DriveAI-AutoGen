// Features/Onboarding/Views/CameraScreen.swift
import SwiftUI

struct CameraScreen: View {
    @StateObject var viewModel: OnboardingViewModel
    @StateObject private var permissionManager = CameraPermissionManager.shared

    var body: some View {
        Group {
            switch permissionManager.status {
            case .notDetermined:
                PermissionRequestView(permissionType: "Kamera") {
                    await permissionManager.requestPermission()
                }
            case .denied, .restricted:
                PermissionDeniedView {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            case .authorized, .authorized:
                CameraView(
                    capturedImage: Binding(
                        get: { viewModel.capturedImage },
                        set: { viewModel.capturedImage = $0 }
                    ),
                    onCapture: { image in
                        Task { await viewModel.capturePhoto(image) }
                    },
                    onDismiss: { viewModel.goBack() }
                )
            @unknown default:
                Text("Unbekannter Kamerastatus")
            }
        }
        .alert("Kamera-Zugriff erforderlich", isPresented: .constant(permissionManager.error != nil)) {
            Button("OK", role: .cancel) { permissionManager.error = nil }
        } message: {
            Text("Bitte aktiviere den Kamerazugriff in den Einstellungen.")
        }
    }
}