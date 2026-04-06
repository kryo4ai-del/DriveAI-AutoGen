import SwiftUI

struct CountdownTimerView: View {
    let remainingSeconds: Int

    var body: some View {
        VStack(spacing: 8) {
            Text("Time Remaining")
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityLabel("Time remaining indicator")

            Text("\(remainingSeconds)s")
                .font(.system(size: 28, weight: .bold, design: .default))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
                .foregroundColor(.primary)
                .accessibilityValue("\(remainingSeconds) seconds remaining")
                .accessibilityAddTraits(.isStaticText)
        }
        .padding()
        .border(Color(UIColor.separator), width: 1)
    }
}