import Combine
import Foundation

// MARK: - ViewModel Protocol (enforces consistency)
protocol ScreenViewModel: ObservableObject {
    associatedtype State
    var state: State { get set }
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }
}

// MARK: - Example: DashboardViewModel
@MainActor
class DashboardViewModel: ScreenViewModel {
    // MARK: - State Enum (replaces multiple @Published variables)
    enum State {
        case idle
        case loaded
    }

    @Published var state: State = .idle
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
}