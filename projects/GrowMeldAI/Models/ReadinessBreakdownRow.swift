import SwiftUI
struct ReadinessBreakdownRow: View {
    let label: String
    let value: Double
    let weight: Int
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(Int(value * 100))%")
                    .font(.headline)
                    .accessibilityLabel("\(label): \(Int(value * 100))%")
            }
            
            Spacer()
            
            ProgressView(value: value)
                .accessibilityHidden(true)  // Duplicate of text above
                .frame(maxWidth: 100)
            
            Text("(\(weight)%)")
                .font(.caption2)
                .foregroundColor(.secondary)
                .accessibilityLabel("Gewicht: \(weight)%")
        }
        .padding(.vertical, 8)
    }
}