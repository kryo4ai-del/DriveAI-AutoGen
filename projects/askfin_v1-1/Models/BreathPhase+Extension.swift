extension BreathPhase: Identifiable {
    var id: String { "\(label)-\(Int(duration))" }
}