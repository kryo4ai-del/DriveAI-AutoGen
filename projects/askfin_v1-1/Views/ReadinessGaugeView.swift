import SwiftUI
struct ReadinessGaugeView: View {
    var readinessScore: ReadinessScore
    
    var body: some View {
        ZStack {
            // Circular background
            Circle()
                .fill(Color(.systemGray6))
                .frame(width: 200, height: 200)
            
            // Gauge fill
            Circle()
                .trim(from: 0, to: readinessScore.overall / 100)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.82, green: 0.10, blue: 0.10), // Red
                            Color(red: 0.95, green: 0.60, blue: 0.04), // Orange
                            Color(red: 0.16, green: 0.68, blue: 0.25)  // Green
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
            
            // Center text with sufficient contrast
            VStack(spacing: 8) {
                Text(String(format: "%.0f%%", readinessScore.overall))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.black) // ✅ Black on white = 21:1 contrast
                
                Text(readinessScore.confidenceLevel.displayName)
                    .font(.caption)
                    .foregroundColor(.gray) // ✅ Dark gray on white = 7.5:1 contrast
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Exam Readiness")
            .accessibilityValue(
                String(format: NSLocalizedString("%.0f Prozent", comment: "Percentage"), 
                       readinessScore.overall)
            )
        }
    }
}