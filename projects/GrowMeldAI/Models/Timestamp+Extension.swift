// Models/Timestamp+Extension.swift
import Foundation

// Since FirebaseFirestore module is unavailable, we provide a pure-Foundation
// Timestamp stand-in that mirrors the Firestore Timestamp API surface.

// MARK: - Timestamp (Firestore-compatible)

/// A portable timestamp type that mirrors `FirebaseFirestore.Timestamp`.
/// When FirebaseFirestore is available in the target, delete this file and
/// import FirebaseFirestore directly.
public struct Timestamp: Codable, Hashable, Sendable {
    public let seconds: Int64
    public let nanoseconds: Int32

    public init(seconds: Int64, nanoseconds: Int32) {
        self.seconds = seconds
        self.nanoseconds = nanoseconds
    }

    public init(date: Date) {
        let ti = date.timeIntervalSince1970
        self.seconds = Int64(ti)
        self.nanoseconds = Int32((ti - Double(Int64(ti))) * 1_000_000_000)
    }
}

// MARK: - Timestamp → Date

extension Timestamp {
    /// Returns a `Date` representation of this timestamp.
    public var dateValue: Date {
        let ti = TimeInterval(seconds) + TimeInterval(nanoseconds) / 1_000_000_000
        return Date(timeIntervalSince1970: ti)
    }
}

// MARK: - Date → Timestamp

extension Date {
    /// Returns a `Timestamp` representation of this date.
    public var firestoreTimestamp: Timestamp {
        return Timestamp(date: self)
    }
}

// MARK: - JSONDecoder helper

extension JSONDecoder {
    /// Decodes a Firestore Timestamp from raw JSON data that contains
    /// `_seconds` and `_nanoseconds` keys.
    func decodeFirestoreTimestamp(_ data: Data) throws -> Timestamp {
        guard
            let container = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let seconds = container["_seconds"] as? Int,
            let nanoseconds = container["_nanoseconds"] as? Int
        else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Invalid Timestamp format: expected '_seconds' and '_nanoseconds' keys."
                )
            )
        }
        return Timestamp(seconds: Int64(seconds), nanoseconds: Int32(nanoseconds))
    }
}