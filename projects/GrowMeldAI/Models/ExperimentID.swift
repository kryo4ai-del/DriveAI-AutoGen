// Models/ExperimentID.swift
import Foundation

struct ExperimentID: Hashable, Codable, RawRepresentable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension ExperimentID: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

// Models/VariantID.swift
struct VariantID: Hashable, Codable, RawRepresentable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension VariantID: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

// Update ExperimentAssignment to use typed IDs
// Struct ExperimentAssignment declared in Models/ABTestingError.swift
