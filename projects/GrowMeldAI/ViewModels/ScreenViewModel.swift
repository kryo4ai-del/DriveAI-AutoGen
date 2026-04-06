import Combine
import Foundation
import SwiftUI

// MARK: - ViewModel Protocol (enforces consistency)
protocol ScreenViewModel: ObservableObject {
    associatedtype State
    var state: State { get set }
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }
}

// MARK: - Example: DashboardViewModel

// MARK: - State Enum (replaces multiple @Published variables)