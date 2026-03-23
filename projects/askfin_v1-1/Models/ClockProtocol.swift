protocol ClockProtocol {
    var now: Date { get }
}

struct SystemClock: ClockProtocol {
    var now: Date { .now }
}

struct MockClock: ClockProtocol {
    var now: Date
}