enum DashboardViewState {
    case loading
    case ready(categories: [Category], progress: [String: Double])
    case error(Error)
}

// Prevents invalid state combinations (e.g., both loading AND ready)