import SwiftUI

struct CameraPermissionPrompt: View {
    @StateObject private var viewModel = CameraPermissionViewModel()

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)

                Text("Camera Access Required")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Please allow camera access to scan and identify your plants.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button(action: {
                    viewModel.requestPermission()
                }) {
                    Text("Allow Camera Access")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: CGFloat(LayoutConstants.buttonHeight))
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(CGFloat(LayoutConstants.mediumRadius))
                        .padding(.horizontal)
                }
                .frame(minWidth: A11yConstants.minTouchTarget, minHeight: A11yConstants.minTouchTarget)
            }
            .padding()
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.alertTitle),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

final class CameraPermissionViewModel: ObservableObject {
    @Published var showAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""

    func requestPermission() {
        alertTitle = "Camera Permission"
        alertMessage = "Please enable camera access in Settings to use this feature."
        showAlert = true
    }
}