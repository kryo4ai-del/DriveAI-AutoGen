import SwiftUI

struct CameraControlsView: View {
    @ObservedObject var viewModel: CameraViewModel

    var body: some View {
        VStack(spacing: 16) {
            Button(action: { viewModel.capturePhoto() }) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(width: 60, height: 60)
            .background(Color.blue)
            .clipShape(Circle())
            .accessibilityLabel("Foto aufnehmen")
            .accessibilityHint("Aktivieren zum Aufnehmen eines Fotos")
            .accessibilityAddTraits(.isButton)

            Button(action: { viewModel.switchCamera() }) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 18, weight: .semibold))
            }
            .frame(width: 44, height: 44)
            .accessibilityLabel("Kamera wechseln")
            .accessibilityHint("Aktivieren zum Wechsel zwischen Vorder- und Rückkamera")

            Button(action: { viewModel.toggleFlash() }) {
                Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash")
                    .font(.system(size: 18, weight: .semibold))
            }
            .frame(width: 44, height: 44)
            .accessibilityLabel(viewModel.isFlashOn ? "Blitz aus" : "Blitz an")
        }
        .padding()
    }
}

class CameraViewModel: ObservableObject {
    @Published var isFlashOn: Bool = false

    func capturePhoto() {}
    func switchCamera() {}
    func toggleFlash() {
        isFlashOn.toggle()
    }
}