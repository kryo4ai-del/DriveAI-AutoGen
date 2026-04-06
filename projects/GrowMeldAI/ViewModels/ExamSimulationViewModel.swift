import Foundation
import Combine

@MainActor
class ExamSimulationViewModel: ObservableObject {
    @Published var remainingSeconds: Int = 0
    @Published var isRunning: Bool = false

    init() {}
}
