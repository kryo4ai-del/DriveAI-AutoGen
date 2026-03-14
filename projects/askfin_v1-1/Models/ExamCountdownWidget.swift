// Views/Components/ExamCountdownWidget.swift

import SwiftUI

struct ExamCountdownWidget: View {
    let readiness: ExamReadiness
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.blue)
                Text("Prüfung in \(readiness.daysUntilExam) Tagen")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Text(readiness.examDate.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundStyle(.secondary)
            
            if readiness.daysUntilExam < 30 {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.orange)
                    Text("Erhöhen Sie die Lernzeit")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Prüfungszähler")
        .accessibilityValue("\(readiness.daysUntilExam) Tage verbleibend")
    }
}

#Preview {
    ExamCountdownWidget(
        readiness: ExamReadiness(
            id: UUID(),
            examDate: Date().addingTimeInterval(86400 * 45),
            readinessScore: 73,
            readinessLevel: .onTrack,
            daysUntilExam: 45,
            totalCategories: 22,
            readyCategoryCount: 18,
            averageStrength: .fair,
            lastUpdated: Date()
        )
    )
}