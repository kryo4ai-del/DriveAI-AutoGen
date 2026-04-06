import SwiftUI

// MARK: - Environment Keys

private struct DataServiceKey: EnvironmentKey {
    static let defaultValue: AnyObject? = nil
}

private struct ProgressServiceKey: EnvironmentKey {
    static let defaultValue: AnyObject? = nil
}

private struct TimerServiceKey: EnvironmentKey {
    static let defaultValue: AnyObject? = nil
}

// MARK: - EnvironmentValues Extension

extension EnvironmentValues {
    var dataService: AnyObject? {
        get { self[DataServiceKey.self] }
        set { self[DataServiceKey.self] = newValue }
    }

    var progressService: AnyObject? {
        get { self[ProgressServiceKey.self] }
        set { self[ProgressServiceKey.self] = newValue }
    }

    var timerService: AnyObject? {
        get { self[TimerServiceKey.self] }
        set { self[TimerServiceKey.self] = newValue }
    }
}