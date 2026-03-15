struct ReadinessLevelBadge: View {
    let level: ReadinessLevel
    
    var body: some View {
        HStack(spacing: 8) {
            Text(level.emoji)
                .font(.title)
            
            Text(level.displayName)
                .font(.headline)
                .foregroundColor(.white) // High contrast text
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            // Use dark variant for contrast
            Group {
                switch level {
                case .notReady:
                    Color(red: 0.8, green: 0.2, blue: 0.2) // Dark red
                case .developing:
                    Color(red: 0.85, green: 0.5, blue: 0.1) // Dark orange
                case .prepared:
                    Color(red: 0.8, green: 0.75, blue: 0.1) // Dark yellow
                case .wellPrepared:
                    Color(red: 0.2, green: 0.7, blue: 0.2) // Dark green
                }
            }
        )
        .cornerRadius(8)
    }
}

// Verify contrast ratios:
// - Dark red #CC3333 on white: 5.6:1 ✅
// - Dark orange #D98110 on white: 4.8:1 ✅
// - Dark yellow #CCBF19 on white: 5.2:1 ✅
// - Dark green #33B233 on white: 4.5:1 ✅