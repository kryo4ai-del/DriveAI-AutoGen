import SwiftUI

/// Keep variant 2 which includes accentColor and statusIcon properties.
/// These enable external customization if needed, though current implementation
/// computes them internally for encapsulation.
struct CategoryPerformanceRow: View {
    let score: CategoryScore
    let backgroundColor: Color
    
    // Enhanced variant properties (from V2) - kept for flexibility
    var accentColor: Color?
    var statusIcon: String?
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(score.category.name)
                    .font(.body)
                    .fontWeight(.semibold)
                
                Text("\(Int(score.percentage))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                ProgressView(value: score.percentage / 100)
                    .tint(computedStatusColor)
                    .frame(width: 60)
                
                Image(systemName: computedStatusIcon)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(computedStatusColor)
                    .frame(width: 24)
            }
        }
        .padding(12)
        .background(backgroundColor)
        .cornerRadius(8)
    }
    
    // Use provided values or compute internally
    private var computedStatusIcon: String {
        statusIcon ?? (
            score.percentage >= 80 ? "checkmark.circle.fill" :
            score.percentage >= 60 ? "exclamationmark.circle.fill" :
            "xmark.circle.fill"
        )
    }
    
    private var computedStatusColor: Color {
        accentColor ?? computeStatusColor()
    }
    
    private func computeStatusColor() -> Color {
        if score.percentage >= 80 {
            return Color(red: 0.2, green: 0.8, blue: 0.2)
        } else if score.percentage >= 60 {
            return Color(red: 1.0, green: 0.6, blue: 0.1)
        } else {
            return Color(red: 0.8, green: 0.2, blue: 0.2)
        }
    }
}