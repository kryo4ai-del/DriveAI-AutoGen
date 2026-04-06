// MARK: - ASO Metadata View
// File: ASOMetadataView.swift
import SwiftUI

/// View for managing App Store metadata with emotional hooks and compliance
struct ASOMetadataView: View {
    @State private var title: String = "DriveAI"
    @State private var subtitle: String = "Fahrschul-Theorieprüfung meistern"
    @State private var keywords: String = "fahrschule, theorieprüfung, führerschein, test, lernen"
    @State private var description: String = """
    Bereite dich optimal auf deine Theorieprüfung vor mit DriveAI.
    Lerne mit echten Prüfungsfragen und werde sicher für die Prüfung.
    """

    @State private var selectedRegion: Region = .germany
    @State private var showEmotionalHooks: Bool = true

    enum Region: String, CaseIterable, Identifiable {
        case germany = "Deutschland"
        case austria = "Österreich"
        case switzerland = "Schweiz"

        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Grundlegende Metadaten")) {
                    TextField("Titel", text: $title)
                    TextField("Untertitel", text: $subtitle)
                        .onChange(of: subtitle) { newValue in
                            subtitle = applyEmotionalHooks(to: newValue)
                        }
                    TextField("Keywords (kommagetrennt)", text: $keywords)
                }

                Section(header: Text("Beschreibung")) {
                    TextEditor(text: $description)
                        .frame(minHeight: 150)
                }

                Section(header: Text("Regionale Anpassung")) {
                    Picker("Region", selection: $selectedRegion) {
                        ForEach(Region.allCases) { region in
                            Text(region.rawValue).tag(region)
                        }
                    }

                    Toggle("Emotionale Hooks aktivieren", isOn: $showEmotionalHooks)
                }

                Section(footer: Text("⚠️ Stelle sicher, dass alle Metadaten den Apple App Store Richtlinien entsprechen. Vermeide übertriebene Leistungsversprechen.")) {
                    // Compliance status
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Compliance: OK")
                    }
                }
            }
            .navigationTitle("ASO Metadaten")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func applyEmotionalHooks(to text: String) -> String {
        guard showEmotionalHooks else { return text }

        let emotionalVariants: [String: String] = [
            "Fahrschul-Theorieprüfung meistern": "Von unsicher zu sicher — Theorieprüfung meistern",
            "Lerne für die Theorieprüfung": "Bereit für die Prüfung? Starte jetzt mit DriveAI",
            "Beste Lern-App für Fahrschüler": "Dein Weg zur bestandenen Prüfung — wir begleiten dich",
            "Theorieprüfung bestehen": "Fast geschafft — nur noch wenige Fragen bis zur Prüfungsreife"
        ]

        return emotionalVariants[text] ?? text
    }
}

// MARK: - Preview
#Preview {
    ASOMetadataView()
}