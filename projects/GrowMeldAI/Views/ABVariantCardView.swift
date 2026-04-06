import SwiftUI

struct ABVariantCardView: View {
    let variant: ABVariant

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(variant.name)
                .font(.headline)
            Text(variant.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Weight: \(variant.weight)%")
                .font(.caption)
                .foregroundColor(.secondary)
            if let impact = variant.impact {
                Text(impact)
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    private var accessibilityDescription: String {
        var parts = [
            "Variant: \(variant.name)",
            variant.description,
            "Weight: \(variant.weight) percent"
        ]
        if let impact = variant.impact {
            parts.append("Impact: \(impact)")
        }
        return parts.joined(separator: ", ")
    }
}

// MARK: - ABVariant Model (minimal working definition if not defined elsewhere)

struct ABVariant: Identifiable {
    let id: UUID
    let name: String
    let description: String
    let weight: Int
    let impact: String?

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        weight: Int,
        impact: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.weight = weight
        self.impact = impact
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        ABVariantCardView(
            variant: ABVariant(
                name: "Variant A",
                description: "Control group with standard onboarding flow",
                weight: 50,
                impact: "+12% conversion"
            )
        )
        ABVariantCardView(
            variant: ABVariant(
                name: "Variant B",
                description: "Experimental group with personalized onboarding",
                weight: 50,
                impact: nil
            )
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}