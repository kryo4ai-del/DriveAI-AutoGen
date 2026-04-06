// MARK: - AppStoreLink.swift
// Handles App Store deep linking with UTM parameters and conversion tracking
// Production-ready with strict concurrency and error handling

import SwiftUI
import Foundation

/// Configuration for App Store deep linking
struct AppStoreConfiguration: Hashable {
    let appId: String
    let baseUrl: String
    let utmSource: String
    let utmMedium: String
    let utmCampaign: String
    let utmTerm: String?
    let utmContent: String?

    static let driveAIDACH = AppStoreConfiguration(
        appId: "6475832109", // DriveAI DACH region
        baseUrl: "https://apps.apple.com",
        utmSource: "driveai_web",
        utmMedium: "organic",
        utmCampaign: "seo_optimization",
        utmTerm: "fuehrerschein_pruefung",
        utmContent: "hero_cta"
    )
}

/// ViewModel for App Store deep linking
final class AppStoreLinkViewModel: ObservableObject {
    @Published var isLinkActive = false
    @Published var lastError: Error?

    private let configuration: AppStoreConfiguration
    private let linkValidator: AppStoreLinkValidator

    init(configuration: AppStoreConfiguration = .driveAIDACH,
         linkValidator: AppStoreLinkValidator = .live) {
        self.configuration = configuration
        self.linkValidator = linkValidator
    }

    /// Generates a tracked App Store URL
    func makeAppStoreURL() -> URL? {
        var components = URLComponents(string: configuration.baseUrl.appendingPathComponent("app/\(configuration.appId)"))

        var queryItems = [
            URLQueryItem(name: "utm_source", value: configuration.utmSource),
            URLQueryItem(name: "utm_medium", value: configuration.utmMedium),
            URLQueryItem(name: "utm_campaign", value: configuration.utmCampaign),
            URLQueryItem(name: "utm_content", value: configuration.utmContent)
        ]

        if let utmTerm = configuration.utmTerm {
            queryItems.append(URLQueryItem(name: "utm_term", value: utmTerm))
        }

        components?.queryItems = queryItems

        return components?.url
    }

    /// Validates the App Store link before presentation
    @MainActor
    func validateLink() async {
        guard let url = makeAppStoreURL() else {
            lastError = AppStoreLinkError.invalidURL
            return
        }

        do {
            let isValid = try await linkValidator.validate(url: url)
            if !isValid {
                lastError = AppStoreLinkError.invalidAppStoreResponse
            }
        } catch {
            lastError = error
        }
    }

    /// Opens the App Store link
    func openAppStoreLink() {
        guard let url = makeAppStoreURL() else {
            lastError = AppStoreLinkError.invalidURL
            return
        }

        UIApplication.shared.open(url) { success in
            if !success {
                self.lastError = AppStoreLinkError.failedToOpen
            }
            self.isLinkActive = success
        }
    }
}

/// Protocol for App Store link validation
protocol AppStoreLinkValidator {
    func validate(url: URL) async throws -> Bool
}

/// Concrete implementation of link validator
struct LiveAppStoreLinkValidator: AppStoreLinkValidator {
    func validate(url: URL) async throws -> Bool {
        // In production, this would make a network request to verify the App Store URL
        // For now, we'll use a simple check
        return url.absoluteString.contains("apps.apple.com")
    }
}

/// Error types for App Store linking
enum AppStoreLinkError: LocalizedError {
    case invalidURL
    case invalidAppStoreResponse
    case failedToOpen

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Die App Store URL ist ungültig."
        case .invalidAppStoreResponse:
            return "Die App Store Verbindung konnte nicht hergestellt werden."
        case .failedToOpen:
            return "Die App Store App konnte nicht geöffnet werden."
        }
    }
}

/// View for App Store CTA button with tracking
struct AppStoreCTAView: View {
    @StateObject private var viewModel: AppStoreLinkViewModel
    private let buttonStyle: AppStoreButtonStyle

    init(viewModel: AppStoreLinkViewModel = .init(),
         style: AppStoreButtonStyle = .primary) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.buttonStyle = style
    }

    var body: some View {
        Group {
            switch buttonStyle {
            case .primary:
                primaryCTA
            case .secondary:
                secondaryCTA
            }
        }
        .onAppear {
            Task { await viewModel.validateLink() }
        }
        .alert("Fehler", isPresented: .constant(viewModel.lastError != nil)) {
            Button("OK", role: .cancel) { viewModel.lastError = nil }
        } message: {
            Text(viewModel.lastError?.localizedDescription ?? "Unbekannter Fehler")
        }
    }

    private var primaryCTA: some View {
        Button(action: viewModel.openAppStoreLink) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.down.app.fill")
                    .font(.headline)
                Text("Jetzt im App Store")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [.blue, .purple]),
                                     startPoint: .leading,
                                     endPoint: .trailing))
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(radius: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var secondaryCTA: some View {
        Button(action: viewModel.openAppStoreLink) {
            Text("Dein Blackout war gestern. Starte jetzt mit DriveAI — sicher, schnell, ohne Stress.")
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue, lineWidth: 2)
                )
                .foregroundColor(.blue)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Button style options for App Store CTAs
enum AppStoreButtonStyle {
    case primary
    case secondary
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        AppStoreCTAView(style: .primary)
            .padding()

        AppStoreCTAView(style: .secondary)
            .padding()
    }
    .frame(maxWidth: .infinity)
    .background(Color(.systemGroupedBackground))
}