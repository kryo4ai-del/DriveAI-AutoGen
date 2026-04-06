// MARK: - FamilySharingConsentView.swift
import SwiftUI

struct FamilySharingConsentView: View {
    @StateObject private var viewModel = FamilySharingConsentViewModel()
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    consentDetailsSection
                    actionButtons
                }
                .padding()
            }
            .navigationTitle("Elterliche Zustimmung")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        isPresented = false
                    }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green.gradient)

            Text("Wichtige Informationen")
                .font(.title2.bold())

            Text("Bitte lies dir die folgenden Punkte sorgfältig durch und bestätige sie mit deinem Fingerabdruck oder Face ID.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var consentDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(viewModel.consentItems) { item in
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.title)
                        .font(.subheadline.bold())

                    Text(item.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let details = item.details {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(details, id: \.self) { detail in
                                Text("• \(detail)")
                                    .font(.caption)
                            }
                        }
                        .padding(.leading, 8)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                viewModel.acceptConsent()
                isPresented = false
            }) {
                Text("Zustimmen und fortfahren")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canAccept)
            .opacity(viewModel.canAccept ? 1.0 : 0.5)

            Button("Nicht jetzt") {
                isPresented = false
            }
            .buttonStyle(.bordered)
        }
    }
}

final class FamilySharingConsentViewModel: ObservableObject {
    @Published var canAccept = false

    let consentItems = [
        ConsentItem(
            title: "Elterliche Verantwortung",
            description: "Ich bestätige, dass ich die elterliche Verantwortung für das Kind trage und dessen Lernfortschritt einsehen darf.",
            details: [
                "Die App ist für Kinder ab 14 Jahren geeignet",
                "Eltern dürfen nur den Lernfortschritt einsehen, nicht die Antworten",
                "Die Zustimmung kann jederzeit widerrufen werden"
            ]
        ),
        ConsentItem(
            title: "Datenschutz (DSGVO)",
            description: "Ich bestätige, dass alle Daten gemäß DSGVO verarbeitet werden.",
            details: [
                "Daten bleiben in der EU",
                "Keine Weitergabe an Dritte",
                "Löschung auf Wunsch möglich"
            ]
        ),
        ConsentItem(
            title: "Kindersicherung",
            description: "Ich bestätige, dass ich die Privatsphäre meines Kindes respektiere.",
            details: [
                "Kein Zugriff auf falsche Antworten",
                "Kein Zugriff auf persönliche Notizen",
                "Keine Überwachung des Lernverhaltens"
            ]
        )
    ]

    func acceptConsent() {
        // TODO: Implement consent storage
        UserDefaults.standard.set(true, forKey: "familySharingConsentGiven")
    }
}

struct ConsentItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let details: [String]?
}

#Preview {
    FamilySharingConsentView(isPresented: .constant(true))
}