enum LocationContextState: Equatable {
    case idle
    case fetching
    case success(UserLocationContext)
    case failed(LocationError)

    static func == (lhs: LocationContextState, rhs: LocationContextState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.fetching, .fetching):
            return true
        case (.success(let lhsContext), .success(let rhsContext)):
            return lhsContext == rhsContext
        case (.failed(let lhsError), .failed(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}