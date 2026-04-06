// Pass coordinator as environment variable instead
@Environment(\.coordinator) var coordinator: AppCoordinator

// In DriveAIApp:
.environment(\.coordinator, coordinator)

// Define environment key:
struct CoordinatorKey: EnvironmentKey {
    static let defaultValue: AppCoordinator? = nil
}

extension EnvironmentValues {
    var coordinator: AppCoordinator? {
        get { self[CoordinatorKey.self] }
        set { self[CoordinatorKey.self] = newValue }
    }
}