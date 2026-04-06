// Sources/Presentation/CameraAccess/Views/CameraAccessView.swift
import SwiftUI

/// View for requesting camera permission
struct CameraAccessView: View {
    @StateObject var viewModel: CameraAccessViewModel

    var body: some View {
        ZStack {
            if viewModel.showPermissionRequest {
                permissionRequestView
            } else if viewModel.isLoading {
                loadingView
            } else if viewModel.hasPermission {
                Color.clear // Transition to camera view
            }
        }
        .alert("Kamera-Zugriff eingeschränkt", isPresented: $viewModel.showRestrictedAlert) {
            Button("OK", role: .cancel) { }
            Button("Einstellungen") {
                if let url = viewModel.openSettings() {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Bitte erlaube den Kamera-Zugriff in den Einstellungen, um fortzufahren.")
        }
        .alert("Zeitüberschreitung", isPresented: $viewModel.showTimeoutAlert) {
            Button("Wiederholen") {
                Task { await viewModel.requestCameraPermission() }
            }
            Button("Abbrechen", role: .cancel) { }
        } message: {
            Text("Die Berechtigungsanfrage hat zu lange gedauert. Bitte versuche es erneut.")
        }
    }

    private var permissionRequestView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)

                Text("Fahrschul-Scan freischalten")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)

                Text("Mit der Kamera scannen wir dein Fahrschulbuch — so übst du realistisch und bist in 3 Wochen prüfungsbereit.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            VStack(spacing: 12) {
                Button(action: {
                    Task { await viewModel.requestCameraPermission() }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Erlauben")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(viewModel.isLoading)

                Button("Später fragen") {
                    viewModel.skipPermission()
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
        }
        .padding()
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)

            Text("Kamera-Zugriff wird angefordert...")
                .font(.headline)
        }
    }
}