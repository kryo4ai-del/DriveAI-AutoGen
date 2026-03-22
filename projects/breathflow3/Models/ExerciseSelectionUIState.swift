// Models/ExerciseSelectionUIState.swift
import Foundation

struct ExerciseSelectionUIState: Equatable {
    var readyTopics: [ExerciseTopic] = []
    var shakeyTopics: [ExerciseTopic] = []
    var notStartedTopics: [ExerciseTopic] = []
}
