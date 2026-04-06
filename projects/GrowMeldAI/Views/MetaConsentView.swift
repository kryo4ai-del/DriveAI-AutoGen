// MetaConsentView.swift
import SwiftUI
import Combine

/// A GDPR-compliant consent view for Meta ads integration
/// Implements autonomy-supportive language and proper memory management
struct MetaConsentView: View {
    @StateObject private var viewModel: MetaConsentViewModel
    @Environment(\.dismiss) private var dismiss

    init(adService: MetaAdServiceProtocol) {
        _viewModel = StateObject(wrappedValue: MetaConsentViewModel(adService: adService))
    }

    var body: some View {
        VStack(spacing: 24) {
            headerView
            consentOptionsView
            actionButtons
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 8)
        .onAppear {
            viewModel.trackScreenView()
        }
    }

    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 40))
                .foregroundColor(.blue)

            Text("Dein Fortschritt bleibt privat")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text("Mit Meta-Anzeigen unterstützen wir dich kostenlos. Du entscheidest, was du teilst.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var consentOptionsView: some View {
        VStack(spacing: 16) {
            Toggle("Personalisierte Anzeigen", isOn: $viewModel.allowPersonalizedAds)
                .toggleStyle(SwitchToggleStyle(tint: .blue))

            Toggle("Anonyme Statistiken", isOn: $viewModel.allowAnonymousStats)
                .toggleStyle(SwitchToggleStyle(tint: .blue))

            if viewModel.showDetailedOptions {
                detailedOptionsView
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var detailedOptionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Detaillierte Einstellungen")
                .font(.headline)

            ForEach(viewModel.detailedOptions) { option in
                Toggle(option.title, isOn: Binding(
                    get: { viewModel.selectedDetailedOptions.contains(option.id) },
                    set: { isSelected in
                        viewModel.toggleDetailedOption(id: option.id, isSelected: isSelected)
                    }
                ))
                .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
        }
        .padding(.top, 8)
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button("Später entscheiden") {
                viewModel.deferConsent()
                dismiss()
            }
            .buttonStyle(.bordered)

            Spacer()

            Button("Speichern") {
                Task {
                    await viewModel.saveConsent()
                    dismiss()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canSave)
        }
    }
}

// MARK: - ViewModel

final class MetaConsentViewModel: ObservableObject {
    @Published var allowPersonalizedAds: Bool = false
    @Published var allowAnonymousStats: Bool = true
    @Published var showDetailedOptions: Bool = false
    @Published var selectedDetailedOptions: Set<String> = []
    @Published var canSave: Bool = false

    private let adService: MetaAdServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(adService: MetaAdServiceProtocol) {
        self.adService = adService
        setupBindings()
    }

    private func setupBindings() {
        Publishers.CombineLatest($allowPersonalizedAds, $allowAnonymousStats)
            .map { $0 || $1 }
            .assign(to: \.canSave, on: self)
            .store(in: &cancellables)
    }

    func toggleDetailedOption(id: String, isSelected: Bool) {
        if isSelected {
            selectedDetailedOptions.insert(id)
        } else {
            selectedDetailedOptions.remove(id)
        }
    }

    @MainActor
    func saveConsent() async {
        let consent = MetaConsent(
            allowPersonalizedAds: allowPersonalizedAds,
            allowAnonymousStats: allowAnonymousStats,
            detailedOptions: Array(selectedDetailedOptions)
        )

        do {
            try await adService.saveConsent(consent)
            adService.loadAdsIfConsented()
        } catch {
            print("Failed to save consent: \(error)")
        }
    }

    func deferConsent() {
        adService.deferConsentDecision()
    }

    func trackScreenView() {
        adService.trackEvent(.consentScreenViewed)
    }
}

// MARK: - Models

struct MetaConsent: Codable, Equatable {
    let allowPersonalizedAds: Bool
    let allowAnonymousStats: Bool
    let detailedOptions: [String]
    let timestamp: Date

    init(allowPersonalizedAds: Bool, allowAnonymousStats: Bool, detailedOptions: [String]) {
        self.allowPersonalizedAds = allowPersonalizedAds
        self.allowAnonymousStats = allowAnonymousStats
        self.detailedOptions = detailedOptions
        self.timestamp = Date()
    }
}

struct DetailedConsentOption: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
}

// MARK: - Protocol

protocol MetaAdServiceProtocol: AnyObject {
    func saveConsent(_ consent: MetaConsent) async throws
    func loadAdsIfConsented() async
    func deferConsentDecision()
    func trackEvent(_ event: MetaAdEvent)
}

enum MetaAdEvent {
    case consentScreenViewed
    case consentSaved
    case adDisplayed
    case adClicked
}

// MARK: - Preview

#Preview {
    MetaConsentView(adService: MockMetaAdService())
        .frame(width: 300, height: 500)
}

final class MockMetaAdService: MetaAdServiceProtocol {
    func saveConsent(_ consent: MetaConsent) async throws {}
    func loadAdsIfConsented() async {}
    func deferConsentDecision() {}
    func trackEvent(_ event: MetaAdEvent) {}
}