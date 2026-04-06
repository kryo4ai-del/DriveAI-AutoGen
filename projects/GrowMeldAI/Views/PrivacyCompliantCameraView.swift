// PrivacyCompliantCameraView.swift
import SwiftUI

/// Privacy-compliant camera view with GDPR-compliant consent flow
struct PrivacyCompliantCameraView: View {
    @StateObject private var viewModel = CameraViewModel()
    @State private var showSettingsAlert = false

    var body: some View {
        Group {
            switch viewModel.authorizationStatus {
            case .notDetermined:
                consentView
            case .authorized:
                CameraView(viewModel: viewModel)
            case .denied, .restricted:
                settingsRequiredView
            @unknown default:
                Text("Unbekannter Kamera-Status")
            }
        }
        .alert("Kamera-Zugriff benötigt", isPresented: $showSettingsAlert) {
            Button("Abbrechen", role: .cancel) { }
            Button("Einstellungen") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Bitte erlaube den Kamera-Zugriff in den Einstellungen, um Fotos für deine Führerscheinvorbereitung zu machen.")
        }
    }

    private var consentView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Foto für Führerschein")
                .font(.title2)
                .fontWeight(.bold)

            Text("Mache ein Foto deines Führerscheins oder Personalausweises, um dich schnell für die Prüfung vorzubereiten. Deine Daten bleiben sicher auf deinem Gerät.")
                .multilineTextAlignment(.center)
                .padding()

            Button(action: {
                Task { await requestCameraAccess() }
            }) {
                Text("Kamera-Zugriff erlauben")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }

    private var settingsRequiredView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("Kamera-Zugriff verweigert")
                .font(.title2)
                .fontWeight(.bold)

            Text("Bitte erlaube den Kamera-Zugriff in den Einstellungen, um diese Funktion zu nutzen.")
                .multilineTextAlignment(.center)
                .padding()

            Button(action: {
                showSettingsAlert = true
            }) {
                Text("Einstellungen öffnen")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }

    @MainActor
    private func requestCameraAccess() async {
        let granted = await viewModel.requestAccess()
        if !granted {
            showSettingsAlert = true
        }
    }
}