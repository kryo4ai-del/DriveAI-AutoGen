import Combine
import Foundation

// MARK: - ViewModel Protocol (enforces consistency)
protocol ScreenViewModel: ObservableObject, Sendable {
    associatedtype State
    @Published var state: State { get set }
    @Published var isLoading: Bool { get set }
    @Published var errorMessage: String? { get set }
}

// MARK: - Example: DashboardViewModel
@MainActor

// MARK: - State Enum (replaces multiple @Published variables)