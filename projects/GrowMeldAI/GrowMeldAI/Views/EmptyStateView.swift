// EmptyStateView.swift
import SwiftUI

struct EmptyStateView: View {
    let title: String
    let subtitle: String
    let image: String
    let showAnimation: Bool

    var body: some View {
        VStack(spacing: 20) {
            if showAnimation {
                Image(systemName: image)
                    .font(.system(size: 60))
                    .symbolEffect(.bounce, value: showAnimation)
                    .foregroundStyle(.blue)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Image(systemName: image)
                    .font(.system(size: 60))
                    .foregroundStyle(.blue.opacity(0.7))
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}