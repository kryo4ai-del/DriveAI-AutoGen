// Features/ExerciseSelection/Views/ExerciseDetailView.swift
import SwiftUI

struct ExerciseDetailView: View {
    let exercise: BreathingExercise
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                Spacer()
            }
            .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack {
                        Text(exercise.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Image(systemName: exercise.category.icon)
                            .foregroundColor(exercise.category.color)
                    }
                    .padding(.horizontal)
                    
                    // Stats
                    HStack(spacing: 16) {
                        StatCard(label: "Duration", value: "\(exercise.duration)s")
                        StatCard(label: "Cycles", value: "\(exercise.cycles)")
                        StatCard(label: "Level", value: exercise.difficulty.displayName)
                    }
                    .padding(.horizontal)
                    
                    // Emotional outcomes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Benefits")
                            .font(.headline)
                        ForEach(exercise.emotionalOutcomes) { outcome in
                            HStack(spacing: 8) {
                                Image(systemName: outcome.icon)
                                    .foregroundColor(.blue)
                                Text(outcome.label)
                                Spacer()
                            }
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Start button
                    Button(action: { /* Navigate to player */ }) {
                        Text("Start Exercise")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(exercise.category.color)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

private struct StatCard: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    NavigationStack {
        ExerciseDetailView(exercise: .boxBreathing)
    }
}