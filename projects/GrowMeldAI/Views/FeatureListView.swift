import SwiftUI
import Foundation
struct FeatureListView: View {
    let features = [
        (icon: "infinity", text: NSLocalizedString("feat.unlimited_practice", comment: "Unlimited practice questions")),
        (icon: "book.circle", text: NSLocalizedString("feat.all_categories", comment: "All exam categories")),
        (icon: "chart.bar", text: NSLocalizedString("feat.detailed_stats", comment: "Detailed progress statistics")),
        (icon: "person.fill", text: NSLocalizedString("feat.no_ads", comment: "Ad-free experience")),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(features, id: \.text) { feature in
                HStack(spacing: 12) {
                    Image(systemName: feature.icon)
                        .foregroundColor(.blue)
                        .frame(width: 24, height: 24)
                        .accessibilityHidden(true)  // Icon is decorative
                    
                    Text(feature.text)
                        .font(.body)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(feature.text)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(
            NSLocalizedString(
                "acc.features_list.title",
                comment: "Premium features list"
            )
        )
        .accessibilityCustomContent(
            "feature_count",
            "\(features.count) features",
            importance: .default
        )
    }
}