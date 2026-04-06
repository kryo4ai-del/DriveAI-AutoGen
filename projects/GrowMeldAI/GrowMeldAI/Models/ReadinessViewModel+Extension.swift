extension ReadinessViewModel.ReadinessStatus {
    var color: Color {
        switch self {
        case .red: return Color("readinessRed")
        case .yellow: return Color("readinessYellow")
        case .green: return Color("readinessGreen")
        }
    }
}