import SwiftUI

struct ReadinessGaugeView: View {
    let readiness: ExamReadiness
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                
                Circle()
                    .trim(from: 0, to: readiness.readinessPercentage / 100)
                    .stroke(gaugeGradient, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: readiness.readinessPercentage)
                
                VStack(spacing: 4) {
                    Text("\(Int(readiness.readinessPercentage))%")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                    
                    Text("Ready")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 200)
            
            // StatBox grid
            HStack(spacing: 12) {
                StatBox(
                    label: "Passed",
                    value: "\(readiness.passedCount)",
                    icon: "checkmark.circle"
                )
                StatBox(
                    label: "Streak",
                    value: "\(readiness.streak)",
                    icon: "flame"
                )
                StatBox(
                    label: "Avg Score",
                    value: "\(Int(readiness.avgScore))%",
                    icon: "target"
                )
            }
        }
        .padding(16)
    }
    
    private var gaugeColor: Color {
        if readiness.readinessPercentage >= 80 {
            return Color(red: 0.2, green: 0.8, blue: 0.2)
        } else if readiness.readinessPercentage >= 60 {
            return Color(red: 1.0, green: 0.6, blue: 0.1)
        } else {
            return Color(red: 0.8, green: 0.2, blue: 0.2)
        }
    }
    
    private var gaugeGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                gaugeColor,
                gaugeColor.opacity(0.6)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct StatBox: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.headline)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}