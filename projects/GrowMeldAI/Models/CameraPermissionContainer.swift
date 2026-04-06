import SwiftUI
// Views/CameraPermissionContainer.swift
struct CameraPermissionContainer: View {
    @StateObject private var viewModel = CameraPermissionViewModel()
    var onPermissionGranted: () -> Void
    var onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            contentForState
        }
        .alert(viewModel.alertTitle, isPresented: $viewModel.showSettingsAlert) {
            Button("Einstellungen", action: viewModel.openSettings)
            Button("Abbrechen", role: .cancel, action: viewModel.dismissAlert)
        } message: {
            Text(viewModel.alertMessage)
        }
    }
    
    @ViewBuilder
    private var contentForState: some View {
        switch viewModel.status {
        case .notDetermined:
            CameraPermissionInitialPrompt(
                isLoading: viewModel.isLoading,
                onAllow: requestPermission,
                onDismiss: onDismiss
            )
            
        case .authorized:
            EmptyView()
                .onAppear(perform: onPermissionGranted)
            
        case .denied:
            CameraPermissionDeniedCard(
                onOpenSettings: viewModel.openSettings
            )
            
        case .restricted:
            CameraPermissionRestrictedCard()
            
        case .unavailable:
            CameraUnavailableCard()
        }
    }
    
    private func requestPermission() {
        Task {
            await viewModel.requestCameraAccess()
        }
    }
}

// Views/CameraPermissionInitialPrompt.swift
struct CameraPermissionInitialPrompt: View {
    let isLoading: Bool
    let onAllow: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "camera.fill")
                .font(.system(size: 56))
                .foregroundColor(.accentColor)
                .accessibilityHidden(true)
            
            VStack(spacing: 8) {
                Text("Kamera-Zugriff benötigt")
                    .font(.title2.bold())
                    .accessibilityAddTraits(.isHeader)
                
                Text("Wir benötigen Zugriff auf deine Kamera, um Dokumente zu scannen und dich zu verifizieren. Deine Daten werden nicht gespeichert oder übertragen.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer(minLength: 32)
            
            VStack(spacing: 12) {
                Button(action: onAllow) {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "camera.fill")
                        }
                        Text("Kamera-Zugriff erlauben")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                }
                .buttonStyle(.prominent)
                .disabled(isLoading)
                .accessibilityIdentifier("camera.permission.allow")
                
                Button("Später", action: onDismiss)
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .accessibilityIdentifier("camera.permission.later")
            }
        }
        .padding(20)
    }
}