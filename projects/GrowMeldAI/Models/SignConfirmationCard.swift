import SwiftUI

struct SignConfirmationCard: View {
    var validationResult: (isValid: Bool, Void) = (isValid: true, ())

    var body: some View {
        Text("Sign Confirmation")
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
}