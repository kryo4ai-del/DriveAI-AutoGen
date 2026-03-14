import SwiftUI

struct CategoryPerformanceRow: View {
    let score: CategoryScore
    
    var backgroundColor: Color {
        if score.percentage >= 0.9 { return Color(.systemGreen).opacity(0.1) }
        if score.percentage >= 0.7 { return Color(.systemYellow).opacity(0.1) }
        return Color(.systemRed).opacity(0.1)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(score.categoryName)
                    .font(.subheadline.bold())
                
                Text("\(score.correct)/\(score.total)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("\(Int(score.percentage * 100))%")
                .font(.headline)
                .monospacedDigit()
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(8)
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(score.categoryName)")
        .accessibilityValue("\(score.correct) von \(score.total), \(Int(score.percentage * 100)) Prozent")
    }
}