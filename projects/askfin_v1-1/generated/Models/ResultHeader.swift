import SwiftUI

struct ResultHeader: View {
    let result: SimulationResult
    
    var body: some View {
        VStack(spacing: 16) {
            // Pass/Fail Badge
            HStack {
                Image(systemName: result.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(result.passed ? .green : .red)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.passed ? "Bestanden!" : "Nicht bestanden")
                        .font(.title2.bold())
                    Text("Du benötigst 90%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Score Display
            VStack(spacing: 8) {
                Text("\(Int(result.score * 100))%")
                    .font(.system(size: 56, weight: .bold, design: .default))
                
                Text("\(result.correctAnswers) von \(result.totalQuestions) Fragen richtig")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                // Progress Bar
                ProgressView(value: result.score)
                    .tint(result.passed ? .green : .orange)
                    .frame(height: 8)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Prüfungsergebnis")
        .accessibilityValue("\(Int(result.score * 100)) Prozent, \(result.correctAnswers) von \(result.totalQuestions) richtig")
    }
}