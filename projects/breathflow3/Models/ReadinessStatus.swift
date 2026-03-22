// MARK: - Domain/Models.swift
import Foundation

enum ReadinessStatus: String, CaseIterable, Codable {
    case stillShaky = "still_shaky"
    case buildingConfidence = "building_confidence"
    case testReady = "test_ready"
    
    var displayText: String {
        switch self {
        case .stillShaky: return "Still Shaky"
        case .buildingConfidence: return "Building Confidence"
        case .testReady: return "Test Ready"
        }
    }
    
    var accessibilityHint: String {
        switch self {
        case .stillShaky:
            return "Red indicator. You need more practice before testing"
        case .buildingConfidence:
            return "Yellow indicator. You're making progress, keep practicing"
        case .testReady:
            return "Green indicator. You're ready to take the test"
        }
    }
    
    var color: Color {
        switch self {
        case .stillShaky: return Color(red: 0.95, green: 0.3, blue: 0.3)
        case .buildingConfidence: return Color(red: 1.0, green: 0.8, blue: 0.0)
        case .testReady: return Color(red: 0.3, green: 0.85, blue: 0.3)
        }
    }
    
    var sortPriority: Int {
        switch self {
        case .testReady: return 3
        case .buildingConfidence: return 2
        case .stillShaky: return 1
        }
    }
}

struct ExerciseSelectionState {
    var exercises: [Exercise] = []
    var selectedExercise: Exercise?
    var isLoading = false
    var error: ExerciseSelectionError?
    var filter: ExerciseFilter = .all
}

enum ExerciseFilter: String, CaseIterable {
    case all = "All"
    case testReady = "Test Ready"
    case inProgress = "In Progress"
    case notStarted = "Not Started"
    
    var predicate: (Exercise) -> Bool {
        switch self {
        case .all: return { _ in true }
        case .testReady: return { $0.readiness == .testReady }
        case .inProgress: return { $0.readiness == .buildingConfidence }
        case .notStarted: return { $0.readiness == .stillShaky }
        }
    }
}

// MARK: - Repository Error Types