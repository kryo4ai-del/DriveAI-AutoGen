// MARK: - Typography (Dynamic Type Compatible)

enum TextStyle {
    case headingLarge
    case headingMedium
    case bodyRegular
    case bodySmall
    case caption
}

extension View {
    func appFont(_ style: TextStyle) -> some View {
        switch style {
        case .headingLarge:
            return self.font(.system(.title, design: .default)).eraseToAnyView()
        case .headingMedium:
            return self.font(.system(.title3, design: .default)).eraseToAnyView()
        case .bodyRegular:
            return self.font(.system(.body, design: .default)).eraseToAnyView()
        case .bodySmall:
            return self.font(.system(.caption, design: .default)).eraseToAnyView()
        case .caption:
            return self.font(.system(.caption2, design: .default)).eraseToAnyView()
        }
    }
}

// Usage:
Text("Frage: ")
    .appFont(.headingMedium)
    .foregroundColor(AppTheme.palette.text)