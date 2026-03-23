import Foundation
import Combine

@MainActor
final class MeditationSetupViewModel: ObservableObject {

    // MARK: - Published State

    @Published var selectedDuration: MeditationDuration = .fiveMinutes
    @Published private(set) var completedSessionCount: Int = 0
    @Published private(set) var currentStreak: Int = 0

    // MARK: - Dependencies

    let service: MeditationSessionServiceProtocol

    init(service: MeditationSessionServiceProtocol = MeditationSessionService()) {
        self.service = service
    }

    // MARK: - Lifecycle

    func onAppear() {
        completedSessionCount = service.completedSessionCount
        currentStreak = service.currentStreak
    }

    // MARK: - Factory

    /// Creates a configured ActiveViewModel sharing this service instance.
    /// Store the result in `@State` — do not call from inside a view builder closure.
    func makeActiveViewModel() -> MeditationActiveViewModel {
        MeditationActiveViewModel(duration: selectedDuration, service: service)
    }
}