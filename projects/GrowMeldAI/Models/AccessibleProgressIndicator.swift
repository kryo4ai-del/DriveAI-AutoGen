import SwiftUI
import os.log

struct AccessibleProgressIndicator: View {
    let label: String
    let current: Int
    let total: Int
    let showPercentage: Bool = true
    
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    private let logger = Logger(subsystem: "com.driveai.accessibility", category: "Progress")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label
            HStack {
                Text(label)
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer()
                
                if showPercentage {
                    Text("\(percentage)%")
                        .font(.subheadline)
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress bar
            ProgressView(value: progress)
                .tint(progressColor)
                .frame(height: 8)
                .background(Color(.systemGray5))
                .cornerRadius(4)
                .accessibilityElement(combining: .all)
                .accessibilityLabel("Fortschritt")
                .accessibilityValue("\(percentage)% abgeschlossen")
                .accessibilityHint("Du hast \(current) von \(total) Fragen beantwortet")
            
            // Context
            Text("\(current) von \(total) abgeschlossen")
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
        }
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 0.3),
            value: progress
        )
        .onAppear {
            validateData()
        }
    }
    
    // MARK: - Data Validation
    
    private func validateData() {
        if current > total {
            logger.warning(
                "Data integrity issue: current(\(self.current)) > total(\(self.total))"
            )
        }
        
        if total < 0 || current < 0 {
            logger.error(
                "Invalid progress values: current=\(self.current), total=\(self.total)"
            )
        }
    }
    
    // MARK: - Computed Properties
    
    private var progress: Double {
        guard total > 0 else { return 0 }
        
        // Clamp to valid range [0, 1]
        let clamped = Double(min(current, total))
        let normalized = clamped / Double(total)
        
        return max(0, min(normalized, 1.0))
    }
    
    private var percentage: Int {
        Int((progress * 100).rounded())
    }
    
    private var progressColor: Color {
        switch percentage {
        case 0..<33:
            return Color(red: 0.8, green: 0.2, blue: 0.2)      // Red
        case 33..<67:
            return Color(red: 1.0, green: 0.65, blue: 0)       // Orange
        default:
            return Color(red: 0.13, green: 0.55, blue: 0.13)   // Green
        }
    }
}

// MARK: - Preview

#Preview("Low Progress") {
    AccessibleProgressIndicator(
        label: "Heutiges Fortschritt",
        current: 5,
        total: 45,
        showPercentage: true
    )
    .padding()
}

#Preview("High Progress") {
    AccessibleProgressIndicator(
        label: "Verkehrszeichen",
        current: 60,
        total: 60,
        showPercentage: true
    )
    .padding()
}