// Views/Components/ActionButtonGroup.swift
import SwiftUI

struct ActionButtonGroup: View {
    let result: SimulationResult
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 12) {
            // Primary CTA: Retry
            Button(action: {}) {
                Label("Nochmal üben", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                    .font(.subheadline.bold())
            }
            .accessibilityLabel("Nochmal üben")
            .accessibilityHint("Startet eine neue Prüfungssimulation")
            
            // Secondary: Home
            Button(action: { dismiss() }) {
                Label("Zur Startseite", systemImage: "house.fill")
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(Color(.systemGray6))
                    .foregroundStyle(.primary)
                    .cornerRadius(12)
                    .font(.subheadline.bold())
            }
            .accessibilityLabel("Zur Startseite")
            .accessibilityHint("Kehrt zum Hauptmenü zurück")
            
            // Tertiary: Practice Weak Categories
            Button(action: {}) {
                Label("Schwache Kategorien üben", systemImage: "target")
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(Color(.systemGray6))
                    .foregroundStyle(.primary)
                    .cornerRadius(12)
                    .font(.subheadline.bold())
            }
            .accessibilityLabel("Schwache Kategorien üben")
            .accessibilityHint("Konzentriert sich auf Kategorien mit schlechterer Leistung")
            
            // Conditional: Ready for Real Exam
            if result.passed {
                Button(action: {}) {
                    Label("Zur echten Prüfung", systemImage: "graduation.cap.fill")
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(Color.green.opacity(0.15))
                        .foregroundStyle(.green)
                        .cornerRadius(12)
                        .font(.subheadline.bold())
                }
                .accessibilityLabel("Zur echten Prüfung")
                .accessibilityHint("Du hast genug Punkte für die offizielle Prüfung")
            }
        }
        .padding(16)
    }
}

#Preview {
    ActionButtonGroup(result: .previewPass)
}