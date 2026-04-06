import SwiftUI
struct ConfidenceMeter: View {
    let confidence: Float
    
    var body: some View {
        VStack(spacing: 8) {
            // Visual meter
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(confidenceColor)
                        .frame(width: geo.size.width * CGFloat(confidence))
                }
            }
            .frame(height: 8)
            
            // ✅ Numeric label for accessibility
            HStack(spacing: 12) {
                Text("Sicherheit:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(Int(confidence * 100))%")
                    .font(.headline)
                    .monospacedDigit()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Erkennungssicherheit")
        .accessibilityValue("\(Int(confidence * 100)) Prozent")
        .accessibilityAddTraits(.updatesFrequently)
    }
    
    private var confidenceColor: Color {
        switch confidence {
        case 0.8...: return .green
        case 0.6..<0.8: return .yellow
        default: return .red
        }
    }
}