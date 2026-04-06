// Models/Experiment.swift

import Foundation

// MARK: - ExperimentAnyCodable
// Renamed to avoid ambiguity with any other AnyCodable definitions in the project

enum ExperimentAnyCodable: Codable {
    case null
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case array([ExperimentAnyCodable])
    case dictionary([String: ExperimentAnyCodable])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([ExperimentAnyCodable].self) {
            self = .array(value)
        } else if let value = try? container.decode([String: ExperimentAnyCodable].self) {
            self = .dictionary(value)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported type for ExperimentAnyCodable"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null:
            try container.encodeNil()
        case .bool(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .dictionary(let value):
            try container.encode(value)
        }
    }
}

extension ExperimentAnyCodable: Equatable {
    static func == (lhs: ExperimentAnyCodable, rhs: ExperimentAnyCodable) -> Bool {
        switch (lhs, rhs) {
        case (.null, .null): return true
        case (.bool(let a), .bool(let b)): return a == b
        case (.int(let a), .int(let b)): return a == b
        case (.double(let a), .double(let b)): return a == b
        case (.string(let a), .string(let b)): return a == b
        case (.array(let a), .array(let b)): return a == b
        case (.dictionary(let a), .dictionary(let b)): return a == b
        default: return false
        }
    }
}

// MARK: - Experiment

struct Experiment: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let active: Bool
    let variants: [Variant]
    let startDate: Date
    let endDate: Date?
    let metadata: [String: String]?

    var isRunning: Bool {
        active && startDate <= Date() && (endDate.map { $0 > Date() } ?? true)
    }
}

// MARK: - Variant

struct Variant: Codable, Identifiable {
    let id: String
    let weight: Double // 0.0 - 1.0
    let config: [String: ExperimentAnyCodable]?
    let metadata: [String: String]?

    var isValid: Bool {
        weight > 0 && weight <= 1.0
    }
}

// MARK: - ExperimentAssignment

// Struct ExperimentAssignment declared in Models/ABTestingError.swift
