import Foundation
import Combine

enum DashboardUIState {
    case loading
    case loaded
    case error(String)
    case noUserProfile
}
