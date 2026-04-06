// MARK: - Screenshot Sequence View
// File: ScreenshotSequenceView.swift
import SwiftUI

/// View for managing the 5-screen App Store screenshot sequence
struct ScreenshotSequenceView: View {
    @State private var screenshots: [Screenshot] = [
        Screenshot(id: UUID(), title: "Lernmodus", description: "Übe mit echten Prüfungsfragen"),
        Screenshot(id: UUID(), title: "Statistiken", description: "Verfolge deinen Fortschritt"),
        Screenshot(id: UUID(), title: "Prüfungssimulation", description: "Teste dich unter realen Bedingungen"),
        Screenshot(id: UUID(), title: "Ergebnis", description: "Analysiere deine Leistung"),
        Screenshot(id: UUID(), title: "Zertifikat", description: "Teile deinen Erfolg")
    ]

    @State private var selectedDevice: Device = .iphone
    @State private var showEmotionalNarrative: Bool = true

    enum Device: String, CaseIterable, Identifiable {
        case iphone = "iPhone"
        case ipad = "iPad"

        var id: String { rawValue }
    }

    struct Screenshot: Identifiable {
        let id: UUID
        var title: String
        var description: String
        var imageName: String = "screenshot1"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Geräteauswahl")) {
                    Picker("Gerät", selection: $selectedDevice) {
                        ForEach(Device.allCases) { device in
                            Text(device.rawValue).tag(device)
                        }
                    }
                }

                Section(header: Text("Screenshot-Sequenz")) {
                    ForEach($screenshots) { $screenshot in
                        VStack(alignment: .leading) {
                            TextField("Titel", text: $screenshot.title)
                            TextField("Beschreibung", text: $screenshot.description)
                                .onChange(of: screenshot.description) { newValue in
                                    screenshot.description = applyEmotionalNarrative(to: newValue)
                                }
                        }
                    }
                    .onDelete { indices in
                        screenshots.remove(atOffsets: indices)
                    }
                }

                Section {
                    Button("Screenshot hinzufügen") {
                        screenshots.append(Screenshot(
                            id: UUID(),
                            title: "Neuer Screenshot",
                            description: "Beschreibung"
                        ))
                    }
                }
            }
            .navigationTitle("Screenshot-Sequenz")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Toggle("Emotionale Erzählung", isOn: $showEmotionalNarrative)
                }
            }
        }
    }

    private func applyEmotionalNarrative(to text: String) -> String {
        guard showEmotionalNarrative else { return text }

        let emotionalMap: [String: String] = [
            "Übe mit echten Prüfungsfragen": "Dein Weg zur bestandenen Prüfung — wir begleiten dich",
            "Verfolge deinen Fortschritt": "Jeder richtige Schritt bringt dich näher ans Ziel",
            "Teste dich unter realen Bedingungen": "Bereit für die große Prüfung? Teste dich jetzt",
            "Analysiere deine Leistung": "Lerne aus jedem Fehler und werde besser",
            "Teile deinen Erfolg": "Stolz auf deine Leistung? Teile sie mit Freunden und Familie"
        ]

        return emotionalMap[text] ?? text
    }
}

#Preview {
    ScreenshotSequenceView()
}