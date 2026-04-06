class CameraGestureHandler: NSObject {
    private let hapticEngine = UIImpactFeedbackGenerator(style: .light)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    func handleTapToFocus(at point: CGPoint) async throws {
        do {
            try await viewModel.setFocusMode(.manual(point))
            
            // ✅ Haptic + audio feedback
            hapticEngine.impactOccurred()
            announceViaAccessibility("Fokus gesetzt")
        } catch {
            selectionFeedback.selectionChanged()
            announceViaAccessibility("Fokus nicht verfügbar")
            throw error
        }
    }
    
    func handlePinchZoom(_ scale: CGFloat) async throws {
        let clampedZoom = max(1.0, min(4.0, scale))
        try await viewModel.setZoom(clampedZoom)
        
        // ✅ Announce zoom level to VoiceOver
        let zoomLevel = Int(clampedZoom * 100)
        announceViaAccessibility("\(zoomLevel) Prozent Zoom")
    }
    
    private func announceViaAccessibility(_ message: String) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}