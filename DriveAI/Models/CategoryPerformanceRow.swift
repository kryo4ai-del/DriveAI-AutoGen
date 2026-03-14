import SwiftUI

struct CategoryPerformanceRow: View {
    let score: CategoryScore
    
    var backgroundColor: Color {
        switch score.performanceLevel {
        case .excellent:
            return Color.green.opacity(0.1)
        case .good:
            return Color.blue.opacity(0.1)
        case .fair:
            return Color.yellow.opacity(0.1)
        case .needsImprovement:
            return Color.red.opacity(0.1)
        }
    }
    
    var accentColor: Color {
        switch score.performanceLevel {
        case .excellent:
            return .green
        case .good:
            return .blue
        case .fair:
            return .yellow
        case .needsImprovement:
            return .red
        }
    }
    
    var statusIcon: String {
        switch score.performanceLevel {
        case .excellent:
            return "checkmark.circle.fill"
        case .good:
            return "checkmark.circle"
        case .fair:
            return "exclamationmark.circle"
        case .needsImprovement:
            return "xmark.circle.fill"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: statusIcon)
                .font(.system(size: 18))
                .foregroundStyle(accentColor)
                .frame(width: 24)
            
            // Category Info
            VStack(alignment: .leading, spacing: 4) {
                Text(score.categoryName)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                
                HStack(spacing: 8) {
                    Text("\(score.correct)/\(score.total)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .foregroundStyle(.secondary)
                    
                    Text(score.performanceLevel.rawValue)
                        .font(.caption2)
                        .foregroundStyle(accentColor)
                }
            }
            
            Spacer()
            
            // Percentage
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(score.percentage * 100))%")
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(.primary)
                
                // Mini Progress Bar
                ProgressView(value: score.percentage, total: 1.0)
                    .tint(accentColor)
                    .frame(width: 60, height: 4)
            }
        }
        .padding(12)
        .background(backgroundColor)
        .cornerRadius(8)
        .padding(.horizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(score.categoryName)
        .accessibilityValue(
            "\(score.correct) von \(score.total) Fragen richtig, \(Int(score.percentage * 100)) Prozent, \(score.performanceLevel.rawValue)"
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        CategoryPerformanceRow(
            score: CategoryScore(
                categoryId: "signs",
                categoryName: "Verkehrszeichen",
                correct: 9,
                total: 10
            )
        )
        
        CategoryPerformanceRow(
            score: CategoryScore(
                categoryId: "rules",
                categoryName: "Vorfahrtsregeln",
                correct: 7,
                total: 10
            )
        )
        
        CategoryPerformanceRow(
            score: CategoryScore(
                categoryId: "safety",
                categoryName: "Fahrzeugsicherheit",
                correct: 5,
                total: 10
            )
        )
    }
    .padding()
}