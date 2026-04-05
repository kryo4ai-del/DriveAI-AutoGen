import Foundation

// MARK: - Unknown

/// A type representing an unknown or unresolved value.
public enum Unknown {

    // MARK: - Nested Types

    /// Represents the reason an entity is unknown.
    public enum Reason: String, Codable, CaseIterable, Sendable {
        case notFound       = "not_found"
        case notLoaded      = "not_loaded"
        case parseFailure   = "parse_failure"
        case networkError   = "network_error"
        case permissionDenied = "permission_denied"
        case undefined      = "undefined"
    }

    // MARK: - Error

    /// Errors that can be thrown when working with unknown values.
    public enum UnknownError: LocalizedError, Sendable {
        case cannotResolve(reason: Reason)
        case missingIdentifier
        case invalidState(description: String)

        public var errorDescription: String? {
            switch self {
            case .cannotResolve(let reason):
                return "Cannot resolve unknown value: \(reason.rawValue)"
            case .missingIdentifier:
                return "Missing identifier for unknown entity."
            case .invalidState(let description):
                return "Invalid state: \(description)"
            }
        }
    }
}

// MARK: - UnknownValue

/// A generic wrapper that represents a value that may or may not be known.
public struct UnknownValue<T>: CustomStringConvertible, CustomDebugStringConvertible {

    // MARK: - State

    private enum State {
        case known(T)
        case unknown(reason: Unknown.Reason, fallback: T?)
    }

    // MARK: - Properties

    private let state: State

    /// Returns `true` if the value is known.
    public var isKnown: Bool {
        if case .known = state { return true }
        return false
    }

    /// Returns `true` if the value is unknown.
    public var isUnknown: Bool { !isKnown }

    /// The known value, or `nil` if unknown.
    public var value: T? {
        switch state {
        case .known(let v):         return v
        case .unknown(_, let fb):  return fb
        }
    }

    /// The reason the value is unknown, or `nil` if it is known.
    public var unknownReason: Unknown.Reason? {
        if case .unknown(let reason, _) = state { return reason }
        return nil
    }

    // MARK: - Init

    /// Creates a known value.
    public init(known value: T) {
        self.state = .known(value)
    }

    /// Creates an unknown value with an optional fallback.
    public init(reason: Unknown.Reason, fallback: T? = nil) {
        self.state = .unknown(reason: reason, fallback: fallback)
    }

    // MARK: - Accessors

    /// Returns the known value or throws if unknown.
    public func resolve() throws -> T {
        switch state {
        case .known(let v):
            return v
        case .unknown(let reason, let fallback):
            if let fb = fallback { return fb }
            throw Unknown.UnknownError.cannotResolve(reason: reason)
        }
    }

    /// Returns the known value or a provided default.
    public func valueOrDefault(_ default: T) -> T {
        return value ?? `default`
    }

    /// Transforms the known value using a closure.
    public func map<U>(_ transform: (T) throws -> U) rethrows -> UnknownValue<U> {
        switch state {
        case .known(let v):
            return UnknownValue<U>(known: try transform(v))
        case .unknown(let reason, _):
            return UnknownValue<U>(reason: reason)
        }
    }

    /// Flat-maps the known value using a closure.
    public func flatMap<U>(_ transform: (T) throws -> UnknownValue<U>) rethrows -> UnknownValue<U> {
        switch state {
        case .known(let v):
            return try transform(v)
        case .unknown(let reason, _):
            return UnknownValue<U>(reason: reason)
        }
    }

    // MARK: - CustomStringConvertible

    public var description: String {
        switch state {
        case .known(let v):
            return "Known(\(v))"
        case .unknown(let reason, let fallback):
            let fb = fallback.map { "fallback: \($0)" } ?? "no fallback"
            return "Unknown(reason: \(reason.rawValue), \(fb))"
        }
    }

    public var debugDescription: String { description }
}

// MARK: - Equatable Conformance

extension UnknownValue: Equatable where T: Equatable {
    public static func == (lhs: UnknownValue<T>, rhs: UnknownValue<T>) -> Bool {
        switch (lhs.state, rhs.state) {
        case (.known(let l), .known(let r)):
            return l == r
        case (.unknown(let lr, let lf), .unknown(let rr, let rf)):
            return lr == rr && lf == rf
        default:
            return false
        }
    }
}

// MARK: - Hashable Conformance

extension UnknownValue: Hashable where T: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch state {
        case .known(let v):
            hasher.combine(0)
            hasher.combine(v)
        case .unknown(let reason, let fallback):
            hasher.combine(1)
            hasher.combine(reason)
            hasher.combine(fallback)
        }
    }
}

// MARK: - Codable Conformance

extension UnknownValue: Codable where T: Codable {

    private enum CodingKeys: String, CodingKey {
        case isKnown, value, reason
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let known = try container.decode(Bool.self, forKey: .isKnown)
        if known {
            let v = try container.decode(T.self, forKey: .value)
            self.state = .known(v)
        } else {
            let reason = try container.decode(Unknown.Reason.self, forKey: .reason)
            let fallback = try container.decodeIfPresent(T.self, forKey: .value)
            self.state = .unknown(reason: reason, fallback: fallback)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch state {
        case .known(let v):
            try container.encode(true, forKey: .isKnown)
            try container.encode(v, forKey: .value)
        case .unknown(let reason, let fallback):
            try container.encode(false, forKey: .isKnown)
            try container.encode(reason, forKey: .reason)
            try container.encodeIfPresent(fallback, forKey: .value)
        }
    }
}

// MARK: - Sendable Conformance

extension UnknownValue: Sendable where T: Sendable {}

// MARK: - ExpressibleByNilLiteral

extension UnknownValue: ExpressibleByNilLiteral {
    /// Initialising with `nil` creates an `.undefined` unknown value.
    public init(nilLiteral: ()) {
        self.state = .unknown(reason: .undefined, fallback: nil)
    }
}

// MARK: - UnknownEntity

/// A concrete model representing an entity whose identity or data is unknown.
public struct UnknownEntity: Identifiable, Codable, Hashable, Sendable {

    // MARK: - Properties

    public let id: UUID
    public let label: String
    public let reason: Unknown.Reason
    public let timestamp: Date
    public let metadata: [String: String]

    // MARK: - Init

    public init(
        id: UUID = UUID(),
        label: String = "Unknown Entity",
        reason: Unknown.Reason = .undefined,
        timestamp: Date = Date(),
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.label = label
        self.reason = reason
        self.timestamp = timestamp
        self.metadata = metadata
    }
}

// MARK: - UnknownRegistry

/// A thread-safe registry for tracking unknown entities.
public final class UnknownRegistry: @unchecked Sendable {

    // MARK: - Singleton

    public static let shared = UnknownRegistry()

    // MARK: - Storage

    private var storage: [UUID: UnknownEntity] = [:]
    private let lock = NSLock()

    // MARK: - Init

    private init() {}

    // MARK: - CRUD

    /// Registers an unknown entity and returns its ID.
    @discardableResult
    public func register(_ entity: UnknownEntity) -> UUID {
        lock.lock()
        defer { lock.unlock() }
        storage[entity.id] = entity
        return entity.id
    }

    /// Retrieves an unknown entity by ID.
    public func entity(for id: UUID) -> UnknownEntity? {
        lock.lock()
        defer { lock.unlock() }
        return storage[id]
    }

    /// Removes an entity from the registry.
    public func remove(id: UUID) {
        lock.lock()
        defer { lock.unlock() }
        storage.removeValue(forKey: id)
    }

    /// Returns all registered unknown entities.
    public func allEntities() -> [UnknownEntity] {
        lock.lock()
        defer { lock.unlock() }
        return Array(storage.values)
    }

    /// Clears all registered entities.
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        storage.removeAll()
    }

    /// Returns the count of registered entities.
    public var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return storage.count
    }
}

// MARK: - UnknownResolver

/// A protocol for types that can attempt to resolve unknown values.
public protocol UnknownResolver {
    associatedtype ResolvedType
    func resolve(entity: UnknownEntity) async throws -> ResolvedType
}

// MARK: - UnknownLogger

/// A lightweight logger for unknown-related events.
public struct UnknownLogger: Sendable {

    public enum Level: String, Sendable {
        case debug   = "DEBUG"
        case info    = "INFO"
        case warning = "WARNING"
        case error   = "ERROR"
    }

    public let subsystem: String
    public let level: Level

    public init(subsystem: String = "com.app.unknown", level: Level = .info) {
        self.subsystem = subsystem
        self.level = level
    }

    public func log(_ message: String, level: Level? = nil) {
        let effectiveLevel = level ?? self.level
        let timestamp = ISO8601DateFormatter().string(from: Date())
        print("[\(timestamp)] [\(subsystem)] [\(effectiveLevel.rawValue)] \(message)")
    }

    public func logUnknown(_ entity: UnknownEntity) {
        log("Unknown entity '\(entity.label)' (id: \(entity.id)) — reason: \(entity.reason.rawValue)", level: .warning)
    }
}

// MARK: - Convenience Extensions

public extension Optional {
    /// Wraps the optional in an `UnknownValue`.
    func asUnknownValue(reason: Unknown.Reason = .undefined) -> UnknownValue<Wrapped> {
        switch self {
        case .some(let v): return UnknownValue(known: v)
        case .none:        return UnknownValue(reason: reason)
        }
    }
}

public extension Result {
    /// Converts a `Result` into an `UnknownValue`.
    func asUnknownValue() -> UnknownValue<Success> {
        switch self {
        case .success(let v): return UnknownValue(known: v)
        case .failure:        return UnknownValue(reason: .undefined)
        }
    }
}