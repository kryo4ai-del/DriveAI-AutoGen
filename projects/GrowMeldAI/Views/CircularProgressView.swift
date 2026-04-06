import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat = 8
    let label: String
    let primaryColor: Color = .blue
    let backgroundColor: Color = Color(.systemGray5)

    @State private var displayProgress: Double = 0

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(backgroundColor, lineWidth: lineWidth)
                    .accessibilityHidden(true)

                Circle()
                    .trim(from: 0, to: displayProgress)
                    .stroke(
                        primaryColor,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: displayProgress)
                    .accessibilityHidden(true)

                VStack(spacing: 4) {
                    Text("\(Int(displayProgress * 100))")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .accessibilityHidden(true)
            }
            .frame(width: 120, height: 120)

            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                displayProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(.easeInOut(duration: 0.8)) {
                displayProgress = newValue
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(String(format: NSLocalizedString("percent_%d", comment: ""), Int(progress * 100)))
    }
}