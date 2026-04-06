struct CameraPreviewView: View {
    var body: some View {
        ZStack {
            CameraPreviewRepresentable()
                .accessibilityLabel("Kamera-Vorschau für Dokumenterfassung")
                .accessibilityHint("Tippe zum Fokussieren auf ein bestimmtes Objekt. Nutze zwei Finger zum Zoomen. Doppeltippe zum Erfassen.")
                .accessibilityElement(children: .combine)
            
            // Focus indicator (visual + haptic feedback)
            FocusIndicatorView()
                .accessibilityHidden(true) // Parent provides label
        }
        .accessibilityAction(.activate) {
            // Trigger capture on VoiceOver select
            viewModel.capturePhoto()
        }
    }
}