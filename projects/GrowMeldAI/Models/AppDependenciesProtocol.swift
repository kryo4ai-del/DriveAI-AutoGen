import SwiftUI
import Combine

// MARK: - AppDependenciesProtocol

protocol AppDependenciesProtocol: ObservableObject {
    var isFirebaseAvailable: Bool { get }
    var isSyncEnabled: Bool { get set }
    var initializationError: Error? { get }
    var localDataService: any LocalDataServiceProtocol { get }
    var authService: (any FirebaseAuthServiceProtocol)? { get }
    var firestoreService: (any FirestoreServiceProtocol)? { get }
    var analyticsService: any AnalyticsServiceProtocol { get }
    var syncCoordinator: (any FirebaseSyncCoordinatorProtocol)? { get }
    var networkMonitor: any NetworkConnectivityMonitorProtocol { get }
    var offlineQueueManager: any OfflineQueueManagerProtocol { get }
    var logger: AppLogger { get }

    func initialize() async
    func disableFirebaseSync()
}

// MARK: - AppDependenciesBox

final class AppDependenciesBox: ObservableObject {
    let wrapped: any AppDependenciesProtocol
    init(_ wrapped: any AppDependenciesProtocol) {
        self.wrapped = wrapped
    }
}

// MARK: - Environment Key

struct AppDependenciesEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppDependenciesBox? = nil
}

extension EnvironmentValues {
    var appDependenciesBox: AppDependenciesBox? {
        get { self[AppDependenciesEnvironmentKey.self] }
        set { self[AppDependenciesEnvironmentKey.self] = newValue }
    }
}