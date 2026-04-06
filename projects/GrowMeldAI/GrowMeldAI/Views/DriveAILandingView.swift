// DriveAILandingView.swift
import SwiftUI

struct DriveAILandingView: View {
    @Environment(\.openURL) private var openURL
    @State private var showPrivacyPolicy = false

    private let appStoreURLs: [Locale: URL] = [
        Locale(identifier: "de_DE"): URL(string: "https://apps.apple.com/de/app/driveai/idYOUR_APP_ID")!,
        Locale(identifier: "de_AT"): URL(string: "https://apps.apple.com/at/app/driveai/idYOUR_APP_ID")!,
        Locale(identifier: "de_CH"): URL(string: "https://apps.apple.com/ch/app/driveai/idYOUR_APP_ID")!,
        Locale(identifier: "en_US"): URL(string: "https://apps.apple.com/us/app/driveai/idYOUR_APP_ID")!
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Hero Section with Emotional Hook
                HeroSection()
                    .padding(.horizontal, 20)
                    .padding(.top, 40)

                // Features Section with Emotional Benefits
                FeaturesSection()
                    .padding(.horizontal, 20)

                // Social Proof
                SocialProofSection()
                    .padding(.horizontal, 20)

                // CTA Section
                CTADownloadSection { locale in
                    appStoreURLs[locale] ?? appStoreURLs[Locale(identifier: "de_DE")]!
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            FooterSection(showPrivacyPolicy: $showPrivacyPolicy)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
    }
}

// MARK: - Subcomponents

private struct HeroSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dein persönlicher Fahrprüfungs-Coach")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)

            Text("Jede Frage bringt dich näher ans Ziel. Lerne effizient, bestehe sicher.")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)

            // App Screenshot Placeholder
            Image("driveai-hero-screenshot")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(12)
                .shadow(radius: 8)
                .padding(.vertical, 20)
        }
    }
}

private struct FeaturesSection: View {
    let features: [Feature] = [
        Feature(icon: "network.slash", title: "Lern überall", subtitle: "Auch ohne Internetverbindung"),
        Feature(icon: "graduationcap", title: "Prüfungssimulation", subtitle: "Echte Testbedingungen trainieren"),
        Feature(icon: "chart.bar", title: "Fortschritt verfolgen", subtitle: "Deine Stärken und Schwächen erkennen"),
        Feature(icon: "text.bubble", title: "Erklärungen verstehen", subtitle: "Jede Frage mit detaillierten Hinweisen"),
        Feature(icon: "clock.arrow.circlepath", title: "Wiederholungsmodus", subtitle: "Schwierige Fragen gezielt üben")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Warum DriveAI?")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible())], spacing: 16) {
                ForEach(features) { feature in
                    FeatureCard(feature: feature)
                }
            }
        }
    }
}

private struct FeatureCard: View {
    let feature: Feature

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: feature.icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(feature.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

private struct SocialProofSection: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Bewertet mit ⭐️ 4.8 auf dem App Store")
                .font(.headline)
                .foregroundColor(.primary)

            HStack {
                AppStoreBadge()
                Spacer()
                AppStoreBadge()
            }
        }
    }

    private struct AppStoreBadge: View {
        var body: some View {
            Image("app-store-badge")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
        }
    }
}

private struct CTADownloadSection: View {
    let getAppStoreURL: (Locale) -> URL

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text("Bereit für deine Prüfung?")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Lade DriveAI jetzt herunter und starte deine Vorbereitung.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                Button(action: {
                    if let url = getAppStoreURL(Locale.current) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.down.app.fill")
                        Text("App Store")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button("Mehr erfahren") {
                    // Navigate to more info
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

private struct FooterSection: View {
    @Binding var showPrivacyPolicy: Bool

    var body: some View {
        VStack(spacing: 16) {
            Divider()

            HStack(spacing: 20) {
                Button("Datenschutz") {
                    showPrivacyPolicy = true
                }
                .font(.footnote)

                Spacer()

                Button("Impressum") {
                    // Navigate to imprint
                }
                .font(.footnote)

                Spacer()

                LanguageSelector()
            }

            Text("© 2024 DriveAI. Alle Rechte vorbehalten.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

private struct LanguageSelector: View {
    @State private var selectedLanguage = "DE"

    var body: some View {
        Menu {
            Button("Deutsch", action: { selectedLanguage = "DE" })
            Button("English", action: { selectedLanguage = "EN" })
        } label: {
            HStack(spacing: 4) {
                Text(selectedLanguage)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .font(.footnote)
        }
    }
}

// MARK: - Preview

#Preview {
    DriveAILandingView()
        .preferredColorScheme(.light)
}