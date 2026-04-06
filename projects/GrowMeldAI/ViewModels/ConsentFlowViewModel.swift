import Foundation
import Combine

@MainActor
final class ConsentFlowViewModel: ObservableObject {
    @Published var isLoading = false
    init() {}
    func acceptAll() {}
    func declineAll() {}
}
