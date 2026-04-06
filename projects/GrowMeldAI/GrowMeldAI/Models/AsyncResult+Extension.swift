import Foundation

/// Wrapper for common async operation patterns
typealias AsyncResult<T> = Result<T, ResilienceError>

extension AsyncResult {
    var value: Success? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    var error: Failure? {
        switch self {
        case .failure(let error):
            return error
        case .success:
            return nil
        }
    }
}

// MARK: - Convenient factory methods

extension AsyncResult {
    /// Execute operation with automatic logging and error conversion
    static func async<T>(
        _ operation: @escaping () async throws -> T,
        logger: ResilienceLogger,
        context: String
    ) async -> AsyncResult<T> {
        do {
            let result = try await operation()
            logger.log(.info, "✅ \(context)")
            return .success(result)
        } catch let error as ResilienceError {
            logger.log(.error, "❌ \(context): \(error.errorDescription ?? "Unknown")")
            return .failure(error)
        } catch {
            let resilError = ResilienceError.operationFailed(error.localizedDescription)
            logger.log(.error, "❌ \(context): \(resilience.errorDescription ?? "Unknown")")
            return .failure(resilError)
        }
    }
}