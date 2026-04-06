import Foundation

enum DashboardViewState {
    case loading
    case ready(categories: [AppCategory], progress: [String: Double])
    case error(Error)
}

struct AppCategory: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
}