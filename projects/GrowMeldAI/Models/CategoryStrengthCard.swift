import SwiftUI

struct CategoryStrengthCard: View {
    let strength: CategoryStrength

    @ScaledMetric(relativeTo: .body) private var cornerRadius: CGFloat = 12
    @ScaledMetric(relativeTo: .body) private var padding: CGFloat = 16

    var body: some View {
        VStack(alignment: .leading, spacing: padding / 2) {
            Text(strength.category.name)
                .font(.headline)
                .accessibilityLabel(strength.accessibilityLabel)

            HStack {
                Text("Genauigkeit:")
                    .font(.body)

                Text("\(strength.accuracyPercentage)%")
                    .font(.title3)
                    .foregroundColor(strength.masteryLevel.color)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Genauigkeit: \(strength.accuracyPercentage) Prozent")

            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(strength.masteryLevel.color)
                    .accessibilityHidden(true)

                Text(strength.masteryLevel.label)
                    .font(.caption)
            }
            .accessibilityElement(children: .combine)
            .accessibilityValue(strength.masteryLevel.accessibilityLabel)

            Text(strength.accessibilityHint)
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
        }
        .padding(padding)
        .background(Color(.systemBackground))
        .cornerRadius(cornerRadius)
    }
}