// MARK: - Localization Preview View
// File: LocalizationPreviewView.swift
import SwiftUI

/// View for previewing localized App Store assets
struct LocalizationPreviewView: View {
    @State private var selectedLanguage: Language = .german
    @State private var showAccessibility: Bool = false

    enum Language: String, CaseIterable, Identifiable {
        case german = "Deutsch"
        case austrianGerman = "Österreichisches Deutsch"
        case swissGerman = "Schweizerdeutsch"

        var id: String { rawValue }
    }

    let sampleTitle = "DriveAI"
    let sampleSubtitle = "Fahrschul-Theorieprüfung meistern"
    let sampleDescription = """
    Bereite dich optimal auf deine Theorieprüfung vor mit DriveAI.
    Lerne mit echten Prüfungsfragen und werde sicher für die Prüfung.
    """

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // App Icon placeholder
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "car.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        )
                        .accessibilityLabel("DriveAI App Icon")

                    // Metadata preview
                    VStack(alignment: .leading, spacing: 8) {
                        Text(sampleTitle)
                            .font(.title.bold())

                        Text(sampleSubtitle)
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Divider()

                        Text("Beschreibung")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(sampleDescription)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .padding(.horizontal)

                    // Screenshot preview
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("8/10 Fragen richtig beantwortet")
                                .font(.headline)
                        }

                        ProgressView(value: 0.8)
                            .tint(.green)

                        Text("Du bist auf einem guten Weg! Nur noch 2 Fragen bis zur Prüfungsreife.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Lokalisierung Vorschau")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Toggle("Barrierefreiheit", isOn: $showAccessibility)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Picker("Sprache", selection: $selectedLanguage) {
                    ForEach(Language.allCases) { lang in
                        Text(lang.rawValue).tag(lang)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
            }
        }
    }
}

#Preview {
    LocalizationPreviewView()
}