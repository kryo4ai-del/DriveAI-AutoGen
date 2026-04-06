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
struct ExperimentAssignment: Codable {
    let id: UUID
    let experimentId: ExperimentID
    let userId: String
    let variantId: VariantID
    let assignedAt: Date
    let cohort: String?

    enum CodingKeys: String, CodingKey {
        case id, userId, assignedAt, cohort
        case experimentId = "experiment_id"
        case variantId = "variant_id"
    }
}