// Services/PermissionService.swift
@MainActor
final class PermissionService: ObservableObject {
    @Published var cameraPermission: AVAuthorizationStatus = .notDetermined
    
    func requestCameraPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLScheme + "://") else { return }
        UIApplication.shared.open(settingsURL)
    }
}

// Services/CameraService.swift
@MainActor

// MARK: - Photo Capture Delegate
private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    let completion: (CMSampleBuffer) -> Void
    
    init(completion: @escaping (CMSampleBuffer) -> Void) {
        self.completion = completion
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                    didFinishProcessingPhoto photo: AVCapturePhoto,
                    error: Error?) {
        guard error == nil, let sampleBuffer = photo.pixelBuffer else {
            return
        }
        
        // Convert CVPixelBuffer to CMSampleBuffer and pass to completion
        completion(sampleBuffer as! CMSampleBuffer) // Simplified - proper conversion needed
    }
}

// MARK: - Video Data Output Delegate
extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                      didOutput sampleBuffer: CMSampleBuffer,
                      from connection: AVCaptureConnection) {
        // Optional: Enable continuous frame processing for preview hints
        // guard state == .idle else { return }
        // Task {
        //     await visionService.prefetchPlantHints(from: sampleBuffer)
        // }
    }
}

// Services/VisionService.swift

// Services/PlantDatabaseService.swift
@MainActor