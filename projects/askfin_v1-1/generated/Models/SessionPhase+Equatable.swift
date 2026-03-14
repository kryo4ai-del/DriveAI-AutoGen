// Models/SessionPhase+Equatable.swift

extension SessionPhase: Equatable {
    static func == (lhs: SessionPhase, rhs: SessionPhase) -> Bool {
        switch (lhs, rhs) {
        case (.brief(let a), .brief(let b)):
            return a == b
        case (.question, .question):
            return true
        case (.reveal(let w1, let m1), .reveal(let w2, let m2)):
            return w1 == w2 && m1 == m2
        case (.summary, .summary):
            return true
        default:
            return false
        }
    }
}