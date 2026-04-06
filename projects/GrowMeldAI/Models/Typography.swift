enum Typography {
    // Use TextStyle directly (automatically scales with Dynamic Type)
    static let h1 = Font.system(.largeTitle, design: .default).weight(.bold)
    static let h2 = Font.system(.title, design: .default).weight(.bold)
    static let h3 = Font.system(.title2, design: .default).weight(.semibold)
    static let body = Font.system(.body, design: .default)
    static let bodyBold = Font.system(.body, design: .default).weight(.semibold)
    static let caption = Font.system(.callout, design: .default)
    static let captionSmall = Font.system(.caption, design: .default)
}