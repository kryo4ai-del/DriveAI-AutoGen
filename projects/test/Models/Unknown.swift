import Foundation

// MARK: - Unknown Model

/// Represents an unknown or unresolved entity.
public struct Unknown: Codable, Hashable, Identifiable, CustomStringConvertible {

    // MARK: - Properties

    public let id: UUID
    public let rawValue: String
    public let metadata: [String: String]
    public let timestamp: Date

    // MARK: - CustomStringConvertible

    public var description: String {
        "Unknown(id: \(id), rawValue: \"\(rawValue)\", timestamp: \(timestamp))"
    }

    // MARK: - Init

    public init(
        id: UUID = UUID(),
        rawValue: String = "",
        metadata: [String: String] = [:],
        timestamp: Date = Date()
    ) {
        self.id = id
        self.rawValue = rawValue
        self.metadata = metadata
        self.timestamp = timestamp
    }
}

// MARK: - Unknown Error

/// Errors that can be thrown when handling unknown entities.
public enum UnknownError: Error, LocalizedError {
    case unresolvable(reason: String)
    case missingContext
    case invalidRawValue(String)
    case timeout

    public var errorDescription: String? {
        switch self {
        case .unresolvable(let reason):
            return "Unresolvable unknown: \(reason)"
        case .missingContext:
            return "Missing context to resolve unknown entity."
        case .invalidRawValue(let value):
            return "Invalid raw value: \"\(value)\"."
        case .timeout:
            return "Resolution timed out."
        }
    }
}

// MARK: - Unknown State

/// Represents the resolution state of an unknown entity.
public enum UnknownState: String, Codable, CaseIterable {
    case pending
    case resolving
    case resolved
    case failed
    case ignored
}

// MARK: - Unknown Resolver Protocol

/// A type that can attempt to resolve an `Unknown` entity.
public protocol UnknownResolving {
    associatedtype Resolved

    /// Attempt to resolve the given unknown entity.
    /// - Parameter unknown: The unknown entity to resolve.
    /// - Returns: A resolved value of the associated type.
    /// - Throws: `UnknownError` if resolution fails.
    func resolve(_ unknown: Unknown) throws -> Resolved
}

// MARK: - Unknown Manager

/// Manages a collection of unknown entities and their resolution states.
public final class UnknownManager {

    // MARK: - Singleton

    public static let shared = UnknownManager()

    // MARK: - Private Storage

    private var store: [UUID: (unknown: Unknown, state: UnknownState)] = [:]
    private let lock = NSLock()

    // MARK: - Init

    private init() {}

    // MARK: - Public API

    /// Register a new unknown entity.
    /// - Parameter unknown: The entity to register.
    public func register(_ unknown: Unknown) {
        lock.lock()
        defer { lock.unlock() }
        store[unknown.id] = (unknown, .pending)
    }

    /// Update the state of a registered unknown entity.
    /// - Parameters:
    ///   - id: The identifier of the entity.
    ///   - state: The new state to apply.
    /// - Throws: `UnknownError.unresolvable` if the entity is not found.
    public func updateState(for id: UUID, to state: UnknownState) throws {
        lock.lock()
        defer { lock.unlock() }
        guard var entry = store[id] else {
            throw UnknownError.unresolvable(reason: "No entity found with id \(id).")
        }
        entry.state = state
        store[id] = entry
    }

    /// Retrieve the current state of an unknown entity.
    /// - Parameter id: The identifier of the entity.
    /// - Returns: The current `UnknownState`, or `nil` if not found.
    public func state(for id: UUID) -> UnknownState? {
        lock.lock()
        defer { lock.unlock() }
        return store[id]?.state
    }

    /// Retrieve all registered unknown entities.
    public func allUnknowns() -> [Unknown] {
        lock.lock()
        defer { lock.unlock() }
        return store.values.map { $0.unknown }
    }

    /// Remove a registered unknown entity.
    /// - Parameter id: The identifier of the entity to remove.
    @discardableResult
    public func remove(id: UUID) -> Unknown? {
        lock.lock()
        defer { lock.unlock() }
        return store.removeValue(forKey: id)?.unknown
    }

    /// Remove all registered unknown entities.
    public func removeAll() {
        lock.lock()
        defer { lock.unlock() }
        store.removeAll()
    }

    /// Filter unknowns by state.
    /// - Parameter state: The state to filter by.
    /// - Returns: An array of `Unknown` entities matching the given state.
    public func unknowns(withState state: UnknownState) -> [Unknown] {
        lock.lock()
        defer { lock.unlock() }
        return store.values
            .filter { $0.state == state }
            .map { $0.unknown }
    }
}

// MARK: - Unknown + Comparable

extension Unknown: Comparable {
    public static func < (lhs: Unknown, rhs: Unknown) -> Bool {
        lhs.timestamp < rhs.timestamp
    }
}

// MARK: - Unknown + ExpressibleByStringLiteral

extension Unknown: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)
    }
}