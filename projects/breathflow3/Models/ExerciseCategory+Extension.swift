// Models/ExerciseCategory+Extension.swift
import Foundation

extension ExerciseCategory {
    var displayName: String {
        switch self {
        case .roadSigns: return "Road Signs"
        case .trafficRules: return "Traffic Rules"
        case .safetyProcedures: return "Safety Procedures"
        case .hazardPerception: return "Hazard Perception"
        case .speedManagement: return "Speed Management"
        }
    }

    var icon: String {
        switch self {
        case .roadSigns: return "triangle.fill"
        case .trafficRules: return "car.fill"
        case .safetyProcedures: return "checklist"
        case .hazardPerception: return "eye.fill"
        case .speedManagement: return "speedometer"
        }
    }
}
