// Views/Components/ExerciseCard.swift
import SwiftUI

struct ExerciseCard: View {
    let exercise: Exercise
    let stats: UserSessionStats?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: exercise.icon)
                        .font(.system(size: 24))
                        .foregroundColor(Color(exercise.color))
                        .frame(width: 40, height: 40)
                        .accessibilityHidden(true)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .accessibilityAddTraits(.isHeader)
                        
                        Text(exercise.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: 8) {
                    DifficultyBadge(difficulty: exercise.difficulty)
                    
                    Text("\(exercise.estimatedDuration) min")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    QuickStatsView(stats: stats)
                }
            }
            .padding(12)
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Exercise: \(exercise.name)")
        .accessibilityHint("\(exercise.estimatedDuration) minutes, \(exercise.difficulty.displayName) difficulty")
    }
}

#Preview {
    ExerciseCard(
        exercise: Exercise(
            id: UUID(),
            name: "Road Signs Quiz",
            description: "Test your knowledge of common road signs",
            category: .roadSigns,
            difficulty: .intermediate,
            estimatedDuration: 10,
            questionCount: 20,
            icon: "triangle.fill",
            color: "yellow"
        ),
        stats: UserSessionStats(
            exerciseId: UUID(),
            completedCount: 3,
            averageScore: 0.85,
            lastAttemptDate: Date(),
            bestScore: 0.95
        ),
        isSelected: false,
        action: {}
    )
}