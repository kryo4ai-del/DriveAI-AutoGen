import SwiftUI
struct CameraControlsView: View {
    var body: some View {
        VStack(spacing: 16) {
            // ✅ PRIMARY: Large capture button (60×60pt)
            Button(action: { viewModel.capturePhoto() }) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 24, weight: .semibold))
            }
            .frame(width: 60, height: 60)
            .background(Color.blue)
            .clipShape(Circle())
            .accessibilityLabel("Foto aufnehmen")
            .accessibilityHint("Aktivieren zum Aufnehmen eines Fotos")
            .accessibilityAddTraits(.isButton)
            
            // ✅ SECONDARY: Camera switch (minimum 44×44pt with padding)
            Button(action: { viewModel.switchCamera() }) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 18, weight: .semibold))
            }
            .frame(width: 44, height: 44)
            .accessibilityLabel("Kamera wechseln")
            .accessibilityHint("Aktivieren zum Wechsel zwischen Vorder- und Rückkamera")
            
            // ✅ TERTIARY: Flash toggle (44×44pt minimum)
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