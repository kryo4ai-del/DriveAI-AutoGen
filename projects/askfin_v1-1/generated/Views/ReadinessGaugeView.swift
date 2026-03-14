import SwiftUI

struct ReadinessGaugeView: View {
    let readiness: ExamReadiness
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Prüfungsbereitschaft")
                .font(.headline)
            
            Gauge(value: readiness.readinessPercentage) {
                Text("0%")
                    .font(.caption2)
            } currentValueLabel: {
                Text("\(Int(readiness.readinessPercentage * 100))%")
                    .font(.title3.bold)
            } minimumValueLabel: {
                Text("0%")
            } maximumValueLabel: {
                Text("100%")
            }
            .gaugeStyle(.accessoryCircular)
            .tint(gaugeColor)
            
            Text(readiness.recommendation)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Deine Prüfungsbereitschaft")
        .accessibilityValue("\(Int(readiness.readinessPercentage * 100)) Prozent")
    }
    
    private var gaugeColor: Color {
        if readiness.readinessPercentage >= 0.85 { return .green }
        if readiness.readinessPercentage >= 0.70 { return .yellow }
        return .orange
    }
}