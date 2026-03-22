struct ExerciseSelectionView: View {
    @State private var viewModel = BreathingViewModel()
    @State private var showBreathingView = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                ForEach(BreathingTechnique.allCases, id: \.self) { tech in
                    TechniqueCard(
                        technique: tech,
                        isSelected: viewModel.selectedTechnique == tech,  // ✓ Single source
                        action: {
                            viewModel.selectedTechnique = tech
                            showBreathingView = true
                        }
                    )
                }
            }
            .navigationDestination(isPresented: $showBreathingView) {
                BreathingView(viewModel: viewModel)  // ✓ Passes ViewModel
            }
        }
    }
}