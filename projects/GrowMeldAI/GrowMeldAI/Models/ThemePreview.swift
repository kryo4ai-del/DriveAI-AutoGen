struct ThemePreview: View {
    @State private var isDark = false
    
    var body: some View {
        VStack {
            Toggle("Dark Mode", isOn: $isDark)
            
            RectangleViews()
                .environment(
                    \.driveAITheme,
                    isDark ? DriveAITheme.dark : DriveAITheme.light
                )
        }
        .padding()
    }
}

struct RectangleViews: View {
    @Environment(\.driveAITheme) var theme
    
    var body: some View {
        VStack {
            Rectangle().fill(theme.background).frame(height: 50)
            Rectangle().fill(theme.surface).frame(height: 50)
            Rectangle().fill(theme.primary).frame(height: 50)
        }
    }
}

#Preview("Light Mode") {
    ThemePreview()
        .environment(\.colorScheme, .light)
}

#Preview("Dark Mode") {
    ThemePreview()
        .environment(\.colorScheme, .dark)
}