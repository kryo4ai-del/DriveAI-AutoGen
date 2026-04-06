struct SignConfirmationCard: View {
    // ... existing code ...
    
    .onAppear {
        if validationResult.isValid {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        } else {
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.warning)
        }
    }
}