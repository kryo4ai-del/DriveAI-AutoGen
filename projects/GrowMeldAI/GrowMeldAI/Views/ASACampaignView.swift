import SwiftUI

/// Main view for managing Apple Search Ads campaigns
struct ASACampaignView: View {
    @StateObject private var viewModel: ASAViewModel

    init(viewModel: ASAViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Kampagnen-Copy")) {
                    ForEach(viewModel.copyVariants) { variant in
                        VStack(alignment: .leading) {
                            Text(variant.headline)
                                .font(.headline)
                            Text(variant.description)
                                .font(.subheadline)
                            if let disclaimer = variant.disclaimer {
                                Text(disclaimer)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete { indices in
                        viewModel.copyVariants.remove(atOffsets: indices)
                    }
                }

                Section(header: Text("Zielgruppe")) {
                    Text("Alter: \(viewModel.targetingParams.ageRange.lowerBound)-\(viewModel.targetingParams.ageRange.upperBound)")
                    Text("Geräte: \(viewModel.targetingParams.deviceTypes.joined(separator: ", "))")
                    Text("Regionen: \(viewModel.targetingParams.geoTargeting.count) Bundesländer")
                }

                Section {
                    switch viewModel.complianceStatus {
                    case .unknown:
                        ProgressView()
                    case .compliant:
                        Label("Alle Compliance-Prüfungen bestanden", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    case .nonCompliant(let reason):
                        VStack(alignment: .leading) {
                            Label("Compliance-Probleme", systemImage: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(reason)
                                .font(.caption)
                        }
                    }
                }

                Section {
                    Button("Standard-Copy wiederherstellen") {
                        viewModel.resetToDefaultCopy()
                    }
                    .disabled(viewModel.complianceStatus == .compliant)

                    Button("Kampagne starten") {
                        // Campaign launch logic would go here
                    }
                    .disabled(!viewModel.isCampaignReady)
                }
            }
            .navigationTitle("Apple Search Ads")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Hinzufügen") {
                        viewModel.addCopyVariant(
                            ASACopyVariant(
                                text: "Neue Variante",
                                headline: "Neue Headline",
                                description: "Neue Beschreibung",
                                emotionalHook: "Emotionaler Haken",
                                disclaimer: "Haftungsausschluss"
                            )
                        )
                    }
                }
            }
        }
    }
}