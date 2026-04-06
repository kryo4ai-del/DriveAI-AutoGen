// MARK: - Compliance Checklist View
// File: ComplianceChecklistView.swift
import SwiftUI

/// View for tracking App Store review compliance
struct ComplianceChecklistView: View {
    @State private var complianceItems: [ComplianceItem] = [
        ComplianceItem(
            id: UUID(),
            title: "Metadaten entsprechen Apple Richtlinien",
            isChecked: false,
            description: "Titel, Untertitel und Beschreibung sind genau und nicht irreführend",
            riskLevel: .low
        ),
        ComplianceItem(
            id: UUID(),
            title: "Keine übertriebenen Leistungsversprechen",
            isChecked: false,
            description: "Keine Behauptungen wie '100% Bestehensquote' oder 'Garantiert bestehen'",
            riskLevel: .high
        ),
        ComplianceItem(
            id: UUID(),
            title: "Screenshots zeigen tatsächliches App-Verhalten",
            isChecked: false,
            description: "Alle Screenshots müssen der aktuellen App-Version entsprechen",
            riskLevel: .medium
        ),
        ComplianceItem(
            id: UUID(),
            title: "App Icon enthält keine offiziellen Logos",
            isChecked: false,
            description: "Keine TÜV, DEKRA oder andere offizielle Logos im Icon",
            riskLevel: .high
        ),
        ComplianceItem(
            id: UUID(),
            title: "Barrierefreiheit erfüllt WCAG AA",
            isChecked: false,
            description: "Alle Texte haben ausreichenden Kontrast und unterstützen Dynamic Type",
            riskLevel: .medium
        ),
        ComplianceItem(
            id: UUID(),
            title: "Lokalisierung entspricht regionalen Richtlinien",
            isChecked: false,
            description: "de-AT und de-CH Varianten entsprechen lokalen App Store Policies",
            riskLevel: .low
        )
    ]

    enum RiskLevel: String {
        case low = "🟢"
        case medium = "🟡"
        case high = "🔴"
    }

    struct ComplianceItem: Identifiable {
        let id: UUID
        var title: String
        var isChecked: Bool
        var description: String
        var riskLevel: RiskLevel
    }

    var body: some View {
        NavigationStack {
            List {
                Section(footer: Text("⚠️ Externe Rechtsberatung empfohlen für kritische Punkte")) {
                    ForEach($complianceItems) { $item in
                        HStack {
                            Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(item.isChecked ? .green : .gray)
                                .onTapGesture {
                                    item.isChecked.toggle()
                                }

                            VStack(alignment: .leading) {
                                HStack {
                                    Text(item.title)
                                    Spacer()
                                    Text(item.riskLevel.rawValue)
                                }

                                if !item.isChecked {
                                    Text(item.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Compliance-Checkliste")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Zurücksetzen") {
                        for index in complianceItems.indices {
                            complianceItems[index].isChecked = false
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ComplianceChecklistView()
}