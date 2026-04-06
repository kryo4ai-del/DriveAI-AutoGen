import SwiftUI

struct CameraAccessCoordinator: View {
    @StateObject private var viewModel = CameraAccessViewModel()
    @Environment(\.cameraContainer) var container
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.permissionState {
                case .notDetermined, .denied:
                    CameraPermissionView(viewModel: viewModel)
                case .authorized:
                    CameraPreviewView(
                        viewModel: CameraPreviewViewModel(
                            cameraSessionManager: container.cameraSessionManager,
                            signRecognitionService: container.signRecognitionService,
                            questionsService: container.questionsService
                        )
                    )
                case .restricted:
                    VStack(spacing: 16) {
                        Image(systemName: "camera.badge.xmark")
                            .font(.system(size: 48))
                            .foregroundColor(.red)
                        
                        Text("Camera Access Restricted")
                            .font(.headline)
                        
                        Text("Your device administrator has restricted camera access.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
            .navigationTitle("Recognize Signs")
        }
    }
}