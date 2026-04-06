struct FeatureBullet: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.primary)  // ✅ Correct
            
            Spacer()
        }
    }
}