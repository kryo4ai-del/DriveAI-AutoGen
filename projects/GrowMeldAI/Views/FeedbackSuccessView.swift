import SwiftUI

struct FeedbackSuccessView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("feedback.success.title")
                .font(.title)
                .multilineTextAlignment(.center)

            Text("feedback.success.message")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Button("feedback.success.back") {
                // Return to previous screen
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    FeedbackSuccessView()
}