static let headline1 = Font.system(.largeTitle, design: .default).weight(.bold)

// Or create scalable system
struct ScalableFont {
    static func headline1() -> Font {
        return .system(.largeTitle, design: .default).weight(.bold)
    }
}