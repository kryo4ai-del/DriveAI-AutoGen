class CameraIdentificationViewModel: ObservableObject {
    @Published var recognitionState: RecognitionState = .idle
    
    @Environment(\.accessibilityAnnouncement) var announcement
    
    private func updateRecognitionState(_ smoothedConfidence: Float) {
        guard case .scanning = recognitionState else { return }
        
        if smoothedConfidence > 0.80 {
            let recognition = currentRecognition
            recognitionState = .recognized(recognition: recognition)
            
            // ✅ Announce immediately
            UIAccessibility.post(notification: .announcement, argument: 
                "Zeichen erkannt: \(recognition?.sign.germanName ?? "Unbekannt"). Sicherheit \(Int(smoothedConfidence * 100))%"
            )
            
            // ✅ Haptic feedback for multi-modal confirmation
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }
    }
}