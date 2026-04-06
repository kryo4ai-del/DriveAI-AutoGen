// Add an ErrorAlert view modifier
struct ErrorAlert: ViewModifier {
    @ObservedObject var viewModel: QuestionViewModel
    
    func body(content: Content) -> some View {
        content
            .alert("Fehler", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
    }
}