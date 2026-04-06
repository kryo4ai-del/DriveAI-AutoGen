import SwiftUI

struct EfficacyMessageView: View {
    let efficacyMessage: String
    let nextStepHint: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .accessibilityHidden(true)

                Text(NSLocalizedString("feedback_title", comment: ""))
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
            }

            Text(efficacyMessage)
                .font(.body)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel("Rückmeldung: \(efficacyMessage)")

            if !nextStepHint.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Label {
                        Text(NSLocalizedString("next_step", comment: ""))
                            .font(.caption)
                    } icon: {
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .foregroundColor(.secondary)

                    Text(nextStepHint)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(6)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Nächster Schritt: \(nextStepHint)")
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    EfficacyMessageView(
        efficacyMessage: "Du wirst schneller besser: Diese Lücke hast du 3× geübt und jetzt verstanden! 💪",
        nextStepHint: "Diese Lernlücke braucht 3 gezielte Übungen in den nächsten 7 Tagen"
    )
    .padding()
}