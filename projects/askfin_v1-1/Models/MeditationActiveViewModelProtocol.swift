// Future: extract protocol
protocol MeditationActiveViewModelProtocol: ObservableObject {
    var breathState: BreathState { get }
    var sessionProgress: Double { get }
    // ...
}