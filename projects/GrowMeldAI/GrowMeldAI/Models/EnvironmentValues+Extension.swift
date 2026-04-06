import SwiftUI

// MARK: - Protocol Definitions

protocol LocalDataService {
    // Minimal protocol definition for environment value
}

protocol UserProgressService {
    // Minimal protocol definition for environment value
}

protocol ExamTimerService {
    // Minimal protocol definition for environment value
}

// MARK: - Default Implementations

final class LocalDataServiceImpl: LocalDataService {
    init() {}
}

final class UserProgressServiceImpl: UserProgressService {
    init() {}
}

final class ExamTimerServiceImpl: ExamTimerService {
    init() {}
}

// MARK: - Environment Keys

private struct LocalDataServiceKey: EnvironmentKey {
    static let defaultValue: any LocalDataService = LocalDataServiceImpl()
}

private struct UserProgressServiceKey: EnvironmentKey {
    static let defaultValue: any UserProgressService = UserProgressServiceImpl()
}

private struct ExamTimerServiceKey: EnvironmentKey {
    static let defaultValue: any ExamTimerService = ExamTimerServiceImpl()
}

// MARK: - EnvironmentValues Extension

extension EnvironmentValues {
    var dataService: any LocalDataService {
        get { self[LocalDataServiceKey.self] }
        set { self[LocalDataServiceKey.self] = newValue }
    }

    var progressService: any UserProgressService {
        get { self[UserProgressServiceKey.self] }
        set { self[UserProgressServiceKey.self] = newValue }
    }

    var timerService: any ExamTimerService {
        get { self[ExamTimerServiceKey.self] }
        set { self[ExamTimerServiceKey.self] = newValue }
    }
}