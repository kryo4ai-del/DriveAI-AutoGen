@MainActor
struct ExerciseSelectionView: View {
    @StateObject private var viewModel: ExerciseSelectionViewModel
    
    init(useCase: ExerciseSelectionUseCaseProtocol) {
        _viewModel = StateObject(wrappedValue: ExerciseSelectionViewModel(useCase: useCase))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.state.isLoading {
                    ProgressView("Loading exercises...")
                        .accessibilityLabel("Loading exercises")
                } else if let error = viewModel.state.error {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.red)
                        Text(error.errorDescription ?? "Unknown error")
                            .multilineTextAlignment(.center)
                        Button("Retry") { viewModel.loadExercises() }
                            .frame(minHeight: 44)
                    }
                    .padding(32)
                } else if viewModel.filteredExercises.isEmpty {
                    Text("No exercises match selected filter")
                        .foregroundColor(.secondary)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredExercises) { exercise in
                                NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                                    ExerciseCardView(exercise: exercise, onSelect: {
                                        viewModel.selectExercise(exercise)
                                    })
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Practice Exercises")
        }
        .onAppear { viewModel.loadExercises() }
    }
}