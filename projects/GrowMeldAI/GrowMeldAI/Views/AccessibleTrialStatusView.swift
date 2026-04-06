struct AccessibleTrialStatusView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var body: some View {
        VStack(alignment: .leading, spacing: dynamicTypeSize > .xLarge ? 16 : 12) {
            Text("Trial Status")
                .font(.headline)
                .lineLimit(2)  // Allow wrap
            
            Text("\(daysRemaining) days remaining")
                .font(.body)  // Use .body, not custom sizing
                .lineLimit(2)
                .accessibilityLabel("Your trial expires in \(daysRemaining) days")
            
            // ✅ Responsive button that grows with text
            Button(action: {}) {
                Text("Upgrade Now")
                    .font(.body)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)  // Grows, never shrinks
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.vertical, dynamicTypeSize > .xLarge ? 8 : 4)
        }
        .padding()
    }
}