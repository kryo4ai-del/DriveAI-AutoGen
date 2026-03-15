import SwiftUI
struct ReadinessScoreCard: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let readiness: ExamReadiness
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(.gray.opacity(0.2), lineWidth: 8)
            
            Circle()
                .trim(from: 0, to: CGFloat(readiness.readinessScore) / 100)
                .stroke(readiness.readinessLevel.color, ...)
                // ✅ Respect accessibility preference
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: 0.6),
                    value: readiness.readinessScore
                )
        }
    }
}