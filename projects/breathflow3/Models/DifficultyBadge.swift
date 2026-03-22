// Views/Components/DifficultyBadge.swift
import SwiftUI

struct DifficultyBadge: View {
    let difficulty: ExerciseDifficulty
    
    private var backgroundColor: Color {
        switch difficulty {
        case .beginner:
            return Color.green.opacity(0.15)
        case .intermediate:
            return Color.orange.opacity(0.15)
        case .advanced:
            return Color.red.opacity(0.15)
        }
    }
    
    private var foregroundColor: Color {
        switch difficulty {
        case .beginner:
            return .green
        case .intermediate:
            return .orange
        case .advanced:
            return .red
        }
    }
    
    var body: some View {
        Text(difficulty.displayName)
            .font(.caption2.weight(.semibold))
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .clipShape(Capsule())
            .accessibilityLabel("Difficulty level: \(difficulty.displayName)")
    }
}

#Preview {
    HStack(spacing: 8) {
        DifficultyBadge(difficulty: .beginner)
        DifficultyBadge(difficulty: .intermediate)
        DifficultyBadge(difficulty: .advanced)
    }
    .padding()
}