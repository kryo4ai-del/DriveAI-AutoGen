import Foundation

enum AsyncTimeoutError: LocalizedError {
    case timedOut(timeInterval: TimeInterval)
    
    var errorDescription: String? {
        switch self {
        case .timedOut(let interval):
            return "Operation timed out after \(Int(interval))s"
        }
    }
}

extension Task where Failure == Error {
    @discardableResult
    static func withTimeout<T>(
        _ interval: TimeInterval,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task<Never, Never>.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                throw AsyncTimeoutError.timedOut(timeInterval: interval)
            }
            
            guard let result = try await group.next() else {
                throw AsyncTimeoutError.timedOut(timeInterval: interval)
            }
            
            group.cancelAll()
            return result
        }
    }
}