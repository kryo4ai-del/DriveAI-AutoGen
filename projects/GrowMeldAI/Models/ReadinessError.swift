import Foundation

enum ReadinessError: LocalizedError {
    case calculationFailed(reason: String)

    var errorDescription: String? {
        switch self {
        case .calculationFailed(let reason): return reason
        }
    }
}
