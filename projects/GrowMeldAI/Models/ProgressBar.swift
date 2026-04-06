import SwiftUI
struct ProgressBar: View {
    let current: Int
    let total: Int
    let color: Color = .blue
    
    var progress: Double {
        guard total > 0 else { return 0 }
        return Double(current) / Double(total)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Fortschritt")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(current)/\(total)")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray4))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * progress)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 8)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Fortschritt: \(current) von \(total) Fragen")
        .accessibilityValue("\(Int(progress * 100))%")
    }
}