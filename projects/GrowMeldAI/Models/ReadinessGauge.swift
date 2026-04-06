import SwiftUI

struct ReadinessGauge: View {
    @ObservedObject var viewModel: ReadinessViewModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color(UIColor.systemGray5), lineWidth: 12)
                
                Circle()
                    .trim(from: 0, to: viewModel.readinessPercentage)
                    .stroke(
                        viewModel.status.color,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    // ✅ ONLY animate if not reducing motion:
                    .animation(
                        reduceMotion ? nil : .easeInOut(duration: 0.6),
                        value: viewModel.readinessPercentage
                    )
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 6) {
                    Text("\(Int(viewModel.readinessPercentage * 100))%")
                        .font(.system(.title, design: .rounded)).fontWeight(.bold)
                    Text(viewModel.status.label)
                        .font(.system(.caption2, design: .rounded)).foregroundColor(.secondary)
                }
            }
            .frame(height: 160)
            .padding()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Prüfungsbereitschaftsmesser")
            .accessibilityValue("\(Int(viewModel.readinessPercentage * 100)) Prozent")
            
            // ... rest of component ...
        }
    }
}