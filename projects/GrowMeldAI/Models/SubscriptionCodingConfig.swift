// Modules/Subscription/Domain/Codable/SubscriptionCodable.swift
// Centralized Codable strategy to avoid duplication

import Foundation

// MARK: - Custom Strategies

struct SubscriptionCodingConfig {
    static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(Self.dateFormatter.string(from: date))
        }
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()
    
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            guard let date = Self.dateFormatter.date(from: dateString) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid ISO8601 date: \(dateString)"
                )
            }
            return date
        }
        return decoder
    }()
}

// MARK: - Discriminated Union Helper

protocol DiscriminatedUnion: Codable {
    associatedtype CaseKey: CodingKey
    var discriminator: String { get }
}

// Usage: Eliminates boilerplate for enum Codable
extension TrialState {
    enum CaseKey: String, CodingKey {
        case active, expiring, expired, converted
        case expiryDate = "expiry_date"
        case purchaseDate = "purchase_date"
    }
}