import Foundation

public enum ErrorReportingFactory {
    
    /// Creates appropriate error reporter based on configuration
    public static func makeErrorReportingService(
        useFirebase: Bool = false,
        userDefaults: UserDefaults = .standard
    ) -> ErrorReportingService {
        #if DEBUG
        // Always use local logger in debug for safer testing
        return LocalErrorLogger(userDefaults: userDefaults)
        #else
        if useFirebase {
            return FirebaseCrashReportingService()
        } else {
            return LocalErrorLogger(userDefaults: userDefaults)
        }
        #endif
    }
}