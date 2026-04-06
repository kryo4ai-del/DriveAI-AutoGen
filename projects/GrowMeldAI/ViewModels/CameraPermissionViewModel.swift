import Foundation
import AVFoundation

@MainActor
final class CameraPermissionViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showSettings = false

    func requestPermission() async {
        isLoading = true
        defer { isLoading = false }

        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            break
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if !granted {
                showSettings = true
            }
        case .denied, .restricted:
            showSettings = true
        @unknown default:
            showSettings = true
        }
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        Task { @MainActor in
            await UIApplication.shared.open(url)
        }
    }
}