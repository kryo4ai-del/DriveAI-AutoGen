import SwiftUI
func refreshExercises() async {
    errorMessage = nil
    await loadExercises()
}

// ---

NavigationLink {
    ExerciseDetailView(exercise: exercise)  // ❌ Not defined
}

// ---

NavigationLink {
    Text("Coming soon: \(exercise.name)")
}

// ---

#Preview {
    EmotionalOutcomeLabel(
        outcomes: [
            // ... truncated
        ]
    )
    .padding()
}

// ---

private let analytics: AnalyticsService = .shared  // ❌ Undefined

// ---

let service = AnalyticsService.shared
service.track(event: .exerciseSelected(id: "123", name: "Box", category: "Calm"))

// ---

private let dataProvider: ExerciseDataProvider  // ❌ Protocol not defined

// ---

NavigationLink {
    ExerciseDetailView(exercise: exercise)  // ❌ Not defined
}

// ---

Task {
    await viewModel.refreshExercises()  // ❌ Method not defined in ViewModel
}

// ---

// This is accepted:
EmotionalOutcome(id: UUID(), label: "x", icon: "x", relevance: 2.5)

// ---

// Current:
catch {
    errorMessage = error.localizedDescription  // Generic fallback
}

// ---

private func loadExercises() async {
    exercises = try await dataProvider.fetchExercises()
    // If view deallocates here, task continues running
}

// ---

#Preview {
    EmotionalOutcomeLabel(
        outcomes: [
            // ... TRUNCATED MID-STRUCT
        ]
    )
    .padding()
}

// ---

Text(exercise.name)
    .font(.headline)  // ❌ Fixed size, ignores Dynamic Type

Text(exercise.microcopy)
    .font(.caption)   // ❌ Too small at default; unreadable at Large

// ---

Text(exercise.microcopy)
       .foregroundColor(.secondary)  // Gray on light gray background

// ---

.background(Color.blue.opacity(0.1))  // Very light blue
   .foregroundColor(.blue)               // Medium blue

// ---

// Secondary text: use darker color
Text(exercise.microcopy)
    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))  // Darker gray
    // Contrast ratio: ~5.1:1 ✓

// Emotional outcome badges: darker background
HStack(spacing: 4) {
    Image(systemName: outcome.icon)
    Text(outcome.label)
}
.font(.caption2)
.padding(.horizontal, 8)
.padding(.vertical, 6)
.background(Color.blue.opacity(0.2))  // More opaque
.foregroundColor(Color(red: 0, green: 0.4, blue: 0.9))  // Darker blue
.cornerRadius(6)

// Difficulty badge: darker border or text
Text(exercise.difficulty.displayName)
    .font(.caption2)
    .fontWeight(.semibold)
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(exercise.category.color.opacity(0.25))  // More opaque
    .foregroundColor(exercise.category.color.opacity(0.9))  // Darker tint
    .cornerRadius(4)

// ---

// Add debug overlay to show contrast ratios
#if DEBUG
.overlay(alignment: .topLeading) {
    Text("CR: 5.1:1")  // Use WebAIM checker
        .font(.caption2)
        .background(Color.black)
        .foregroundColor(.white)
}
#endif

// ---

var sortedOutcomes: [EmotionalOutcome] {
    outcomes.sorted { $0.relevance > $1.relevance }
}

// In view:
ForEach(sortedOutcomes.prefix(2)) { outcome in
    HStack(spacing: 4) {
        Image(systemName: outcome.icon)
        Text(outcome.label)
    }
    .fontWeight(outcome == sortedOutcomes.first ? .semibold : .regular)
    .opacity(outcome == sortedOutcomes.first ? 1.0 : 0.7)
}

// ---

// Add to ExerciseCardView:
HStack(spacing: 8) {
    Text("Pattern:")
        .font(.caption)
        .foregroundColor(.secondary)
    
    HStack(spacing: 4) {
        Text("\(exercise.breathPattern.inhale)in")
            .font(.caption2)
        Text("\(exercise.breathPattern.hold)hold")
            .font(.caption2)
        Text("\(exercise.breathPattern.exhale)ex")
            .font(.caption2)
    }
    .padding(4)
    .background(Color.blue.opacity(0.1))
    .cornerRadius(4)
}

// ---

// Add to ViewModel:
var hasViewedCategories: Bool {
    UserDefaults.standard.bool(forKey: "exerciseSelection.viewedAllCategories")
}

@ViewBuilder
var filterUI: some View {
    if !hasViewedCategories && selectedCategory == nil {
        QuickStartPrompt()  // "How are you feeling?" + 3 buttons
    } else {
        ExerciseFilterBar(...)  // Full 5 categories
    }
}

// ---

// In ExerciseCardView, replace difficulty badge:
VStack(alignment: .leading, spacing: 2) {
    Text("Level")
        .font(.caption2)
        .fontWeight(.semibold)
        .foregroundColor(.secondary)
    
    HStack(spacing: 4) {
        ForEach(0..<progressionLevel, id: \.self) { _ in
            Image(systemName: "circle.fill")
                .font(.caption2)
                .foregroundColor(exercise.category.color)
        }
        ForEach(0..<(3 - progressionLevel), id: \.self) { _ in
            Image(systemName: "circle")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

private var progressionLevel: Int {
    switch exercise.difficulty {
    case .beginner: return 1
    case .intermediate: return 2
    case .advanced: return 3
    }
}