import SwiftUI

struct ExerciseSelectionView: View {
    @StateObject private var viewModel = ExerciseSelectionViewModel()
    @Namespace private var animation
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ExerciseFilterBar(
                    selectedCategory: $viewModel.selectedCategory,
                    categories: ExerciseCategory.allCases
                )
                .padding()
                .background(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                
                contentView
            }
            .navigationTitle("Breathing Exercises")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.errorMessage {
            ErrorStateView(message: error) {
                Task { await viewModel.refreshExercises() }
            }
        } else if viewModel.filteredExercises.isEmpty {
            EmptyStateView(category: viewModel.selectedCategory)
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredExercises) { exercise in
                        NavigationLink(
                            destination: ExerciseDetailView(exercise: exercise)
                        ) {
                            ExerciseCardView(exercise: exercise)
                                .matchedGeometryEffect(
                                    id: exercise.id,
                                    in: animation
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Error State

private struct ErrorStateView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Something went wrong")
                .font(.headline)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onRetry) {
                Text("Try Again")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Empty State

private struct EmptyStateView: View {
    let category: ExerciseCategory?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wind")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No exercises found")
                .font(.headline)
            
            if let category = category {
                Text("Try browsing other categories like \(category.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("Check back soon for new breathing exercises")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ExerciseSelectionView()
}