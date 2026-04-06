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

    public var failureReason: String? {
        switch self {
        case .unresolvable(let reason): return reason
        case .missingContext:          return "No context was provided."
        case .invalidRawValue(let v):  return "Raw value '\(v)' could not be parsed."
        case .timeout:                 return "The operation exceeded the allowed time."
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .unresolvable:    return "Provide additional information and retry."
        case .missingContext:  return "Supply a valid context before resolving."
        case .invalidRawValue: return "Check the raw value format and try again."
        case .timeout:         return "Retry the operation or increase the timeout limit."
        }
    }
}

// MARK: - Unknown State

/// Represents the resolution state of an unknown entity.
public enum UnknownState: String, Codable, CaseIterable {
    case pending    = "pending"
    case resolving  = "resolving"
    case resolved   = "resolved"
    case failed     = "failed"
    case ignored    = "ignored"

    public var isTerminal: Bool {
        switch self {
        case .resolved, .failed, .ignored: return true
        case .pending, .resolving:         return false
        }
    }

    public var displayName: String {
        rawValue.capitalized
    }
}

// MARK: - Unknown Resolver Protocol

/// A type that can attempt to resolve an `Unknown` into a concrete value.
public protocol UnknownResolving {
    associatedtype Resolved

    /// Attempt to resolve the given unknown entity.
    /// - Parameter unknown: The unknown entity to resolve.
    /// - Returns: A resolved value of the associated type.
    /// - Throws: `UnknownError` if resolution fails.
    func resolve(_ unknown: Unknown) throws -> Resolved
}

// MARK: - Unknown Repository Protocol

/// A type that stores and retrieves `Unknown` entities.
public protocol UnknownRepository {
    func save(_ unknown: Unknown) throws
    func fetch(byID id: UUID) throws -> Unknown?
    func fetchAll() throws -> [Unknown]
    func delete(byID id: UUID) throws
}

// MARK: - In-Memory Unknown Repository

/// A thread-safe, in-memory implementation of `UnknownRepository`.
public final class InMemoryUnknownRepository: UnknownRepository {

    // MARK: - Private Storage

    private var store: [UUID: Unknown] = [:]
    private let lock = NSLock()

    // MARK: - Init

    public init() {}

    // MARK: - UnknownRepository

    public func save(_ unknown: Unknown) throws {
        lock.lock()
        defer { lock.unlock() }
        store[unknown.id] = unknown
    }

    public func fetch(byID id: UUID) throws -> Unknown? {
        lock.lock()
        defer { lock.unlock() }
        return store[id]
    }

    public func fetchAll() throws -> [Unknown] {
        lock.lock()
        defer { lock.unlock() }
        return Array(store.values).sorted { $0.timestamp < $1.timestamp }
    }

    public func delete(byID id: UUID) throws {
        lock.lock()
        defer { lock.unlock() }
        store.removeValue(forKey: id)
    }
}

// MARK: - Unknown Manager

/// Coordinates creation, storage, and resolution of `Unknown` entities.
public final class UnknownManager<Resolver: UnknownResolving> {

    // MARK: - Dependencies

    private let repository: UnknownRepository
    private let resolver: Resolver
    private(set) var stateMap: [UUID: UnknownState] = [:]
    private let lock = NSLock()

    // MARK: - Init

    public init(repository: UnknownRepository, resolver: Resolver) {
        self.repository = repository
        self.resolver   = resolver
    }

    // MARK: - Public API

    /// Creates and persists a new `Unknown` entity.
    @discardableResult
    public func create(rawValue: String, metadata: [String: String] = [:]) throws -> Unknown {
        let unknown = Unknown(rawValue: rawValue, metadata: metadata)
        try repository.save(unknown)
        setState(.pending, for: unknown.id)
        return unknown
    }

    /// Attempts to resolve an `Unknown` entity by its ID.
    /// - Returns: The resolved value, or `nil` if the entity was not found.
    public func resolve(id: UUID) throws -> Resolver.Resolved? {
        guard let unknown = try repository.fetch(byID: id) else { return nil }
        setState(.resolving, for: id)
        do {
            let result = try resolver.resolve(unknown)
            setState(.resolved, for: id)
            return result
        } catch {
            setState(.failed, for: id)
            throw error
        }
    }

    /// Returns the current state for a given ID.
    public func state(for id: UUID) -> UnknownState {
        lock.lock()
        defer { lock.unlock() }
        return stateMap[id] ?? .pending
    }

    /// Marks an unknown entity as ignored.
    public func ignore(id: UUID) {
        setState(.ignored, for: id)
    }

    /// Returns all stored unknown entities.
    public func allUnknowns() throws -> [Unknown] {
        try repository.fetchAll()
    }

    // MARK: - Private Helpers

    private func setState(_ state: UnknownState, for id: UUID) {
        lock.lock()
        defer { lock.unlock() }
        stateMap[id] = state
    }
}

// MARK: - String Resolver (Concrete Example)

/// A simple resolver that returns the raw string value of an `Unknown`.
public struct StringUnknownResolver: UnknownResolving {
    public typealias Resolved = String

    public init() {}

    public func resolve(_ unknown: Unknown) throws -> String {
        guard !unknown.rawValue.isEmpty else {
            throw UnknownError.invalidRawValue(unknown.rawValue)
        }
        return unknown.rawValue
    }
}

// MARK: - Unknown Extensions

public extension Unknown {

    /// Returns `true` when the raw value is empty.
    var isEmpty: Bool { rawValue.isEmpty }

    /// Returns a copy with updated metadata.
    func adding(metadata key: String, value: String) -> Unknown {
        var updated = metadata
        updated[key] = value
        return Unknown(id: id, rawValue: rawValue, metadata: updated, timestamp: timestamp)
    }

    /// Returns a copy with a new raw value.
    func withRawValue(_ newValue: String) -> Unknown {
        Unknown(id: id, rawValue: newValue, metadata: metadata, timestamp: timestamp)
    }
}

// MARK: - Collection Extensions

public extension Collection where Element == Unknown {

    /// Filters to only non-empty unknowns.
    var nonEmpty: [Unknown] { filter { !$0.isEmpty } }

    /// Groups unknowns by a metadata key.
    func grouped(byMetadataKey key: String) -> [String: [Unknown]] {
        Dictionary(grouping: self) { $0.metadata[key] ?? "" }
    }
}