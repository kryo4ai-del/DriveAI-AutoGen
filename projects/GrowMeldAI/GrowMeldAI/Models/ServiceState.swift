import Foundation

enum ServiceState: Equatable, Hashable, Sendable {
    case ready
    case fallback(reason: String)
    case error(Error)
    
    static func == (lhs: ServiceState, rhs: ServiceState) -> Bool {
        switch (lhs, rhs) {
        case (.ready, .ready):
            return true
        case (.fallback(let lReason), .fallback(let rReason)):
            return lReason == rReason
        case (.error(let lError), .error(let rError)):
            return lError.localizedDescription == rError.localizedDescription
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .ready:
            hasher.combine("ready")
        case .fallback(let reason):
            hasher.combine("fallback")
            hasher.combine(reason)
        case .error(let error):
            hasher.combine("error")
            hasher.combine(error.localizedDescription)
        }
    }
}
