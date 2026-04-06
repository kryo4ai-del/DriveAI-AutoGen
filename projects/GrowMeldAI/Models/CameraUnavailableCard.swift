import SwiftUI

struct CameraUnavailableCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.slash.fill")
                .font(.system(size: 48))
                .foregroundColor(Color.gray)

            Text("Kamera nicht verfügbar")
                .font(.headline)
                .multilineTextAlignment(.center)

            Text("Ihr Gerät unterstützt keine Kamerafunktion.")
                .font(.body)
                .multilineTextAlignment(.center)

            Text("Bitte verwenden Sie ein Gerät mit Kamera, um fortzufahren.")
                .font(.footnote)
                .foregroundColor(Color.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .padding()
    }
}