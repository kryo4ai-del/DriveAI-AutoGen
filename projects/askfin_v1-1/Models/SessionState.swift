import SwiftUI

// MARK: - Session State

enum SessionState: Equatable {
    case idle
    case countdown(Int)
    case breathing
    case paused
    case completing
    case complete(BreathSession)
    case failed(String)

    static func == (lhs: SessionState, rhs: SessionState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):                           return true
        case (.countdown(let a), .countdown(let b)):   return a == b
        case (.breathing, .breathing):                 return true
        case (.paused, .paused):                       return true
        case (.completing, .completing):               return true
        case (.complete(let a), .complete(let b)):     return a.id == b.id
        case (.failed(let a), .failed(let b)):         return a == b
        default:                                       return false
        }
    }
}

// MARK: - ViewModel

@MainActor