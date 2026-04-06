// Views/Components/FallbackExplanationView.swift
import SwiftUI

struct FallbackExplanationView: View {
    let question: Question
    let selectedAnswerId: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                Text("Erklärung")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            Text(explanationText)
                .font(.caption)
                .foregroundColor(.primary)
                .lineLimit(nil)
            
            Text("Quelle: Amtliche Fragenkatalog")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(8)
    }
    
    private var explanationText: String {
        // In production, fetch from question.explanationText (offline database)
        question.explanationText ?? "Diese Frage basiert auf den amtlichen Richtlinien der Straßenverkehrsordnung."
    }
}

#Preview {
    FallbackExplanationView(
        question: Question(
            id: "1",
            text: "Was ist richtig?",
            answers: [],
            correctAnswerId: "a",
            category: .rightOfWay,
            explanationText: "Rechts vor Links gilt immer, außer Verkehrsschilder regeln es anders."
        ),
        selectedAnswerId: "b"
    )
    .padding()
}