struct StreakBadge: View {
    let count: Int
    var size: CGSize = CGSize(width: 60, height: 60)
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(AppTheme.colors.warning)
            
            Text("\(count)")
                .font(.driveAIBodyEmphasis)
                .foregroundColor(AppTheme.colors.warning)
        }
        .frame(width: size.width, height: size.height)
        .background(AppTheme.colors.surfaceSecondary)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.colors.warning.opacity(0.3), lineWidth: 2)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Streak Abzeichen")
        .accessibilityValue("\(count) Tage")
    }
}