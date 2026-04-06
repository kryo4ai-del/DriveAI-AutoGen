// MARK: - FeaturesGridView.swift
import SwiftUI

struct FeaturesGridView: View {
    let features: [Feature]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(features) { feature in
                    FeatureCardView(feature: feature)
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 200)
    }
}
