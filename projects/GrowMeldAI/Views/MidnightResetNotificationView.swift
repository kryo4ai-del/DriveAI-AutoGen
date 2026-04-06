import SwiftUI
import Foundation
struct MidnightResetNotificationView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 32))
                .accessibilityHidden(true)
                .opacity(reduceMotion ? 1 : 0.7)  // Skip pulsing if motion reduced
                .animation(reduceMotion ? .none : .easeInOut(duration: 1.5).repeatForever(), value: UUID())
            
            Text("🌙 Deine Tagesquota setzt sich zurück")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            
            Text("Noch eine Frage bevor es Mitternacht wird?")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}