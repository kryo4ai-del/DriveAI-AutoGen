import SwiftUI
struct ProgressSummaryView: View {
    let categoryName: String
    let correct: Int
    let total: Int
    
    var percentage: Double {
        total > 0 ? (Double(correct) / Double(total)) * 100 : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(categoryName)
                    .font(.headline)
                
                Spacer()
                
                // Numeric label (required for accessibility)
                Text("\(correct)/\(total)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Beantwortete Fragen")
                    .accessibilityValue("\(correct) von \(total)")
            }
            
            // Progress bar with accessible value
            ProgressView(value: percentage / 100)
                .tint(percentage >= 70 ? .green : .orange)
                .accessibilityLabel("\(categoryName) Fortschritt")
                .accessibilityValue("\(Int(percentage))%")
        }
        .accessibilityElement(children: .combine)
    }
}