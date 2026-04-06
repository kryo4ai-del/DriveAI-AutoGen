import SwiftUI

struct SignConfirmationCard: View {
    var validationResult: (isValid: Bool, message: String) = (isValid: true, message: "")

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