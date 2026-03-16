import SwiftUI

// MARK: - ReadinessScoreGauge

/// Circular gauge displaying the readiness score percentage and label.
///
/// Color is resolved from the asset catalog via `ReadinessLabel.colorName`.
/// A DEBUG assertion fires immediately if the catalog entry is absent,
/// with a visible `.pink` fallback so the gap is never silent (HIGH-002).
struct ReadinessScoreGauge: View {

    let score: ReadinessScore

    private let lineWidth: CGFloat = 14
    private let diameter: CGFloat  = 160

    var body: some View {
        ZStack {
            // Track ring
            Circle()
                .stroke(Color(.systemFill), lineWidth: lineWidth)
                .frame(width: diameter, height: diameter)

            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(score.value))
                .stroke(
                    gaugeColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: diameter, height: diameter)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8), value: score.value)

            // Centre content
            VStack(spacing: 4) {
                Text("\(score.percentage) %")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())

                Label(score.label.rawValue, systemImage: score.label.systemImage)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(gaugeColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(lineWidth + 8)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "Bereitschaftswert: \(score.percentage) Prozent, \(score.label.rawValue)"
        )
        #if DEBUG
        .onAppear { score.label.assertColorAssetExists() }
        #endif
    }

    // MARK: - Private

    /// Resolves the asset-catalog color with a visible fallback in DEBUG
    /// builds when the named entry is absent (HIGH-002).
    private var gaugeColor: Color {
        #if DEBUG
        guard UIColor(named: score.label.colorName) != nil else {
            return .pink
        }
        #endif
        return Color(score.label.colorName)
    }
}

// MARK: - DEBUG Asset Validation

#if DEBUG
private extension ReadinessScore.ReadinessLabel {
    /// Asserts that the expected asset-catalog color exists.
    /// Fires at view appearance so missing assets are caught in development,
    /// not in a release build where `Color(name)` silently clears.
    func assertColorAssetExists() {
        assert(
            UIColor(named: colorName) != nil,
            """
            Missing color asset '\(colorName)' for ReadinessLabel '\(rawValue)'.
            Add it to Assets.xcassets before shipping.
            """
        )
    }
}
#endif

// MARK: - Preview
// TODO: Preview requires ReadinessScore convenience init