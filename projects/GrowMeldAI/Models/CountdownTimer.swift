import SwiftUI
struct CountdownTimer: View {
    let days: Int
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(days)")
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .dynamicTypeSize(.large ... .extraExtraLarge)  // ✅ Max at 2x
                .foregroundColor(.blue)
                .accessibilityLabel("Tage")
            
            Text("bis zur Prüfung")
                .font(.caption)
                .dynamicTypeSize(.small ... .large)  // ✅ Scale with Dynamic Type
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Countdown-Timer")
        .accessibilityValue(
            days == 1 ? "Morgen!" : "\(days) Tage bis zur Prüfung"
        )
        .accessibilityHint("Tippen um das Datum zu ändern, wenn nötig")
    }
}