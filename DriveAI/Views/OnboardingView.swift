struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack {
            Text("Welcome to DriveAI!")
                .font(.largeTitle)
                .padding()
            Button("Start") {
                viewModel.completeOnboarding()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}