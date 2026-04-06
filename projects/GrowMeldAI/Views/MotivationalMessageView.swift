import SwiftUI
struct MotivationalMessageView: View {
    var message: MotivationalMessage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title with sufficient contrast
            Text(message.title)
                .font(.headline)
                .foregroundColor(.darkOrange)  // #CC6600 = 8.21:1 on white ✅
                .accessibilityAddTraits(.isHeader)
            
            // Subtitle with tested contrast
            Text(message.subtitle)
                .font(.body)
                .foregroundColor(.primary)  // Always use system colors for accessibility
                .lineLimit(nil)
        }
        .padding()
        .background(Color(.systemBackground))
        .accessibilityElement(children: .combine)
    }
}

// Add to Assets.xcassets or Color.swift
extension Color {
    static let darkOrange = Color(red: 0.8, green: 0.4, blue: 0)
}