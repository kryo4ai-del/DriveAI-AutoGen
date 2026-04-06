// Services/Crashlytics/CrashReportingService+Convenience.swift
extension CrashReportingService {
    /// Log a data integrity issue (e.g., corrupted question JSON)
    func recordDataCorruption(
        entity: String,
        reason: String,
        userAction: String? = nil
    ) async {
        let context = ErrorContext(
            category: .database,
            userAction: userAction ?? "data_corruption",
            metadata: ["entity": entity, "reason": reason]
        )
        
        let error = AppError.dataCorruption(entity: entity, reason: reason)
        await recordError(error, context: context)
    }
    
    /// Log a file system error
    func recordFileAccessFailure(
        path: String,
        operation: String,
        underlyingError: Error?
    ) async {
        let context = ErrorContext(
            category: .system,
            userAction: operation,
            metadata: ["path": path]
        )
        
        let error = underlyingError ?? AppError.fileAccessFailed(path: path)
        await recordError(error, context: context)
    }
}