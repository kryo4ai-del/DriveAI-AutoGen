enum LocationContextState: Equatable {
    case idle
    case fetching
    case success(UserLocationContext)
    case failed(LocationError)
}

@MainActor