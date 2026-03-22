// Models/ExerciseCategory.swift
import Foundation

enum ExerciseCategory: String, Codable, CaseIterable, Sendable, Identifiable {
    case roadSigns
    case trafficRules
    case safetyProcedures
    case hazardPerception
    case speedManagement

    var id: String { rawValue }
}
