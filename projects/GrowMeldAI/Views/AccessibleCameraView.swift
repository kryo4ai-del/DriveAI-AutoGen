struct AccessibleCameraView: View {
    @State private var useTextMode = false
    
    var body: some View {
        if useTextMode {
            // Fallback: Text input or image upload
            Form {
                Section(header: Text("Pflanzenbeschreibung")) {
                    TextField("Blattform, Farbe, etc.", text: $description)
                }
            }
        } else {
            CameraPreviewView()
        }
        
        Button(action: { useTextMode.toggle() }) {
            Image(systemName: useTextMode ? "camera.fill" : "textformat")
            Text(useTextMode ? "Zur Kamera" : "Text-Modus")
        }
        .accessibilityLabel(Text(useTextMode ? "Kamera verwenden" : "Text-Beschreibung eingeben"))
    }
}