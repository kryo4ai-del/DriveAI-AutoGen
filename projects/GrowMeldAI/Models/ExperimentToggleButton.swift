// AFTER (✅ Accessible size)
import SwiftUI
struct ExperimentToggleButton: View {
    var body: some View {
        Button(action: { /* toggle */ }) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 24))
                .frame(width: 44, height: 44)  // ✅ Minimum size
                .contentShape(Rectangle())  // Extend tap area
        }
        .accessibilityLabel("Toggle experiment")
        .accessibilityHint("Double-tap to enable or disable this experiment")
        .accessibilityAddTraits(.isButton)
    }
}