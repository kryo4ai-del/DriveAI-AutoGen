struct SignInView: View {
    var body: some View {
        VStack {
            formSection
                .disabled(viewModel.isLoading)
            
            AsyncButton(...).disabled(!viewModel.isFormValid || viewModel.isLoading)
        }
        .opacity(viewModel.isLoading ? 0.6 : 1.0)
    }
}