struct AccessibilityAnnouncement: ViewModifier {
    let message: String
    let triggerValue: Bool
    
    func body(content: Content) -> some View {
        content
            .onChange(of: triggerValue) { _, newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        AccessibilityNotification.Announcement(message).post()
                    }
                }
            }
    }
}

// Usage:
.modifier(AccessibilityAnnouncement(
    message: "Offline-Modus aktiviert...",
    triggerValue: isVisible
))