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
}
