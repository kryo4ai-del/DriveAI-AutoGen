enum LocationContextResolutionResult {
    case determined(LocationContext)
    case indeterminate  // Data loading
    case error(Error)
}
