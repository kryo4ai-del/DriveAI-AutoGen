struct FeatureLockBadge: View {
    let feature: UnlockableFeature
    let isUnlocked: Bool
    let onTap: () -> Void
    
    var body: some View {
        if !isUnlocked {
            Button(action: onTap) {
                Image(systemName: "lock.fill")
                    .font(.body)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)  // ✅ Meets 44x44 minimum
                    .background(
                        Circle()
                            .fill(Color.accentColor)
                            .shadow(radius: 2)
                    )
            }
            .accessibilityLabel("\(feature.displayName) freischalten")
            .accessibilityHint("Antippen zum Anzeigen von Premium-Features")
            // For iPad: ensure hit target is 44x44 in both orientations
            .frame(minHeight: 44, minWidth: 44)
        }
    }
}