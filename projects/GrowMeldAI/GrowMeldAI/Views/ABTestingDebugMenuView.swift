import SwiftUI

// MARK: - Minimal ABTest types if not defined elsewhere

struct ABTestVariant: Identifiable {
    let id: String
    let name: String
    let percentile: Int
}

struct ABTest: Identifiable {
    let id: String
    let name: String
    let description: String?
    let variants: [ABTestVariant]
}

// MARK: - Minimal ABTestingService

class DefaultABTestingService {
    static let shared = DefaultABTestingService()

    private init() {}

    func getActiveTests() -> [ABTest] {
        // Return mock data for debug purposes
        return [
            ABTest(
                id: "onboarding_flow",
                name: "Onboarding Flow",
                description: "Tests different onboarding experiences",
                variants: [
                    ABTestVariant(id: "control", name: "Control", percentile: 50),
                    ABTestVariant(id: "variant_a", name: "Variant A", percentile: 50)
                ]
            ),
            ABTest(
                id: "paywall_design",
                name: "Paywall Design",
                description: "Tests paywall layout variations",
                variants: [
                    ABTestVariant(id: "control", name: "Control", percentile: 33),
                    ABTestVariant(id: "variant_a", name: "Variant A", percentile: 33),
                    ABTestVariant(id: "variant_b", name: "Variant B", percentile: 34)
                ]
            )
        ]
    }
}

// MARK: - ABTestingDebugMenuView

struct ABTestingDebugMenuView: View {
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Toggle button
            Button(action: { isExpanded.toggle() }) {
                HStack(spacing: 8) {
                    Image(systemName: "slider.horizontal.3")
                        .accessibilityHidden(true) // Icon is decorative

                    Text("A/B Testing")
                        .font(.headline)
                }
            }
            .accessibilityLabel(Text("A/B Testing Menu"))
            .accessibilityHint(Text(isExpanded ? "Collapse menu" : "Expand to view active tests"))
            .accessibilityAddTraits(.isButton)

            // Divider
            Divider()
                .accessibilityHidden(true)

            if isExpanded {
                ABTestListView()
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel(Text("Active A/B Tests"))
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .accessibilityElement(children: .contain)
    }
}

// MARK: - ABTestListView

struct ABTestListView: View {
    let tests: [ABTest] = DefaultABTestingService.shared.getActiveTests()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(tests) { test in
                VStack(alignment: .leading, spacing: 4) {
                    Text(test.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .accessibilityLabel(Text("Test: \(test.name)"))

                    if let description = test.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .accessibilityLabel(Text("Description: \(description)"))
                    }

                    Text("Variants: \(test.variants.count)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .accessibilityLabel(Text("\(test.variants.count) variants"))

                    HStack(spacing: 8) {
                        ForEach(test.variants, id: \.id) { variant in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(variant.name)
                                    .font(.caption)
                                    .fontWeight(.semibold)

                                Text("\(variant.percentile)%")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel(
                                Text("Variant \(variant.name): \(variant.percentile) percent")
                            )
                        }
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel(
                    Text(accessibilityLabelForTest(test))
                )
            }
        }
    }

    private func accessibilityLabelForTest(_ test: ABTest) -> String {
        let variantSummary = test.variants
            .sorted { $0.id < $1.id }
            .map { "\($0.name) \($0.percentile)%" }
            .joined(separator: ", ")

        return "\(test.name): \(variantSummary)"
    }
}

// MARK: - Preview

#Preview {
    ABTestingDebugMenuView()
        .padding()
}