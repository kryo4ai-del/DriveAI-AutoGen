// Views/Screens/ExamSimulationScreen.swift (TBD)
import SwiftUI

struct ExamSimulationScreen: View {
    @EnvironmentObject var examService: ExamSimulationService
    @Environment(\.preferredColorScheme) var colorScheme
    @Environment(\.accessibilityReduceMotion) var reduceMotion // ← ADD THIS
    
    var body: some View {
        VStack {
            // ✓ Respect reduceMotion
            if reduceMotion {
                // Static timer (no animation)
                Text(timeFormattedStatic)
                    .font(.headline)
            } else {
                // Animated timer
                Text(timeFormatted)
                    .font(.headline)
                    .transition(.opacity) // Minimal animation
            }
        }
    }
    
    var timeFormatted: String {
        let minutes = Int(examService.timeRemaining) / 60
        let seconds = Int(examService.timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}