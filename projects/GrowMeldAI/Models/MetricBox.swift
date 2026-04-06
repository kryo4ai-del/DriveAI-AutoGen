import SwiftUI
struct MetricBox: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .accessibilityHidden(true)  // ✅ Mark decorative
            
            Text(title)
                .font(.caption)
            
            Text(value)
                .font(.headline)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        // ✅ Container label combines elements
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(title): \(value)"))
        .accessibilityValue(Text(value))
    }
}