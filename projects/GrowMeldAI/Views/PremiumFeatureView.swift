// PremiumFeatureView.swift
import SwiftUI

struct PremiumFeatureView: View {
    @StateObject private var viewModel: PremiumFeatureViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: PremiumFeatureViewModel = PremiumFeatureViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                loadingView
            case .loaded(let feature):
                contentView(feature: feature)
            case .purchased(let feature):
                successView(feature: feature)
            case .error(let errorState):
                errorView(errorState: errorState)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.loadFeatures()
        }
    }

    // MARK: - Subviews
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.5)

            Text("Lade Premium-Features...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func contentView(feature: PremiumFeature) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hero Section
                heroSection(feature: feature)

                // Features List
                featuresList(feature: feature)

                // Purchase Button
                purchaseButton(feature: feature)
            }
            .padding()
        }
    }

    @ViewBuilder
    private func successView(feature: PremiumFeature) -> some View {
        VStack(spacing: 32) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)

            VStack(spacing: 16) {
                Text("Premium freigeschaltet!")
                    .font(.title.bold())

                Text("Vielen Dank für deinen Kauf. Du kannst jetzt alle Features nutzen.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }

            Button(action: { dismiss() }) {
                Text("Loslegen")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    @ViewBuilder
    private func errorView(errorState: PremiumFeatureViewModel.ErrorState) -> some View {
        VStack(spacing: 24) {
            Image(systemName: errorState.iconName)
                .font(.system(size: 64))
                .foregroundStyle(errorState.type.color)

            VStack(spacing: 16) {
                Text(errorState.title)
                    .font(.title.bold())

                Text(errorState.message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }

            if errorState.type == .legalBlocked {
                Button(action: {
                    // In real app, this would open a support ticket or legal info
                    UIApplication.shared.open(URL(string: "https://driveai.app/legal")!)
                }) {
                    Text("Mehr Informationen")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            } else {
                Button(action: { Task { await viewModel.loadFeatures() } }) {
                    Text("Erneut versuchen")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }

    // MARK: - Component Views
    private func heroSection(feature: PremiumFeature) -> some View {
        VStack(spacing: 16) {
            Text(feature.title)
                .font(.title.bold())
                .multilineTextAlignment(.center)

            Text(feature.subtitle)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(feature.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            HStack {
                Text("Einmalig")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(feature.price)
                    .font(.title3.bold())
            }
        }
    }

    private func featuresList(feature: PremiumFeature) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Was du erhältst:")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(feature.features) { featureItem in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: featureItem.iconName)
                        .font(.title2)
                        .foregroundStyle(.blue)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(featureItem.title)
                            .font(.subheadline.bold())

                        Text(featureItem.description)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private func purchaseButton(feature: PremiumFeature) -> some View {
        Button(action: {
            Task { await viewModel.purchaseFeature(feature) }
        }) {
            HStack {
                if case .loading = viewModel.state {
                    ProgressView()
                } else {
                    Image(systemName: "lock.open.fill")
                }

                Text("Jetzt entsperren – \(feature.price)")
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.state == .loading)
        .controlSize(.large)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        PremiumFeatureView()
    }
}

// MARK: - Extensions
extension PremiumFeatureViewModel.ErrorState.ErrorType {
    var color: Color {
        switch self {
        case .network: .orange
        case .purchaseFailed: .red
        case .legalBlocked: .purple
        case .unknown: .gray
        }
    }
}

extension PremiumFeature.Feature {
    var iconName: String {
        // Fallback to a default icon if the specified one doesn't exist
        let validIcons = ["infinity", "lightbulb", "chart.line", "icloud", "checkmark", "star", "bolt"]
        return validIcons.contains(iconName) ? iconName : "checkmark"
    }
}