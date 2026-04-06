struct CrashReportingConfig: Sendable {
    let isEnabled: Bool
    let logLevel: LogLevel  // verbose, normal, minimal
    let piiRedactionEnabled: Bool
    let maxQueueSize: Int
    let dataRetentionDays: Int
    let firebaseProjectID: String?  // None = test/mock
    
    enum LogLevel { case verbose, normal, minimal }
    
    static let production = CrashReportingConfig(
        isEnabled: true,
        logLevel: .normal,
        piiRedactionEnabled: true,
        maxQueueSize: 100,
        dataRetentionDays: 90,
        firebaseProjectID: "driveai-prod"
    )
    
    static let testingMocked = CrashReportingConfig(
        isEnabled: true,
        logLevel: .verbose,  // More detailed for debugging
        piiRedactionEnabled: true,
        maxQueueSize: 10,
        dataRetentionDays: 0,
        firebaseProjectID: nil  // Use MockFirebaseService
    )
}