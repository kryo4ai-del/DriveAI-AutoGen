struct ExerciseSelectionUIState: Equatable {  // ✅ Declared
    var readyTopics: [ExerciseTopic] = []
    var shakeyTopics: [ExerciseTopic] = []
    var notStartedTopics: [ExerciseTopic] = []
    // ❌ But ExerciseTopic.Equatable is manual; 
    // If property changes, SwiftUI won't diff correctly
}