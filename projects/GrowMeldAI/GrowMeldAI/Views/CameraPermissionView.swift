// Sources/Features/Camera/Views/CameraPermissionView.swift
import SwiftUI

/// View for handling camera permission requests
struct CameraPermissionView: View {
    @StateObject var viewModel: CameraPermissionViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "camera.viewfinder")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)

            Text("camera.permission.title")
                .font(.title)
                .fontWeight(.semibold)

            Text("camera.permission.description")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 16)
            }

            Spacer()

            Button(action: {
                Task { await viewModel.requestPermission() }
            }) {
                Text("camera.permission.button.request")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(viewModel.isLoading)
        }
        .padding()
        .background(Color(.systemBackground))
        .navigationTitle("camera.navigation.title")
        .alert("camera.permission.denied.title", isPresented: $viewModel.showSettings) {
            Button("camera.permission.denied.settings", role: .cancel) {
                viewModel.openSettings()
            }
            Button("camera.permission.denied.cancel", role: .destructive) {
                // Do nothing, just dismiss
            }
        } message: {
            Text("camera.permission.denied.message")
        }
    }
}