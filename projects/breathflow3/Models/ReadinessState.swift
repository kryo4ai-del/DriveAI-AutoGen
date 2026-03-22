enum ReadinessState: Equatable, Hashable {
    // ...
    var accentColor: Color {
        switch self {
        case .topicsMastered: return .green  // ✅ ~5.8:1
        case .stillShaky: return Color(red: 0.9, green: 0.6, blue: 0)  // ✅ #E69900 = 5.2:1
        case .notStarted: return .gray  // ✅ ~4.8:1
        }
    }
}