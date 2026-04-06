// UI/Components/ProgressRing.swift
import SwiftUI

struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let ringColor: Color
    let backgroundColor: Color

    init(progress: Double, lineWidth: CGFloat = 12, ringColor: Color = .green, backgroundColor: Color = .gray.opacity(0.2)) {
        self.progress = min(max(progress, 0), 1)
        self.lineWidth = lineWidth
        self.ringColor = ringColor
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(ringColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: progress)

            VStack(spacing: 4) {
                Text("\(Int(progress * 100))%")
                    .font(.headline)
                    .contentTransition(.numericText())

                Text("Bereitschaft")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Exam readiness: \(Int(progress * 100)) percent"))
        .accessibilityValue(Text("\(Int(progress * 100)) percent"))
        .frame(width: 80, height: 80)
    }
}

// Preview
struct ProgressRing_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ProgressRing(progress: 0.75)
            ProgressRing(progress: 0.3, ringColor: .orange)
            ProgressRing(progress: 1.0, ringColor: .green, backgroundColor: .green.opacity(0.2))
        }
        .padding()
    }
}