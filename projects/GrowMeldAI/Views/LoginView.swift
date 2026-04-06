// ❌ BROKEN CODE
struct LoginView: View {
    @State var viewModel: AuthViewModel  // ← New instance every time view reloads
    
    var body: some View {
        // User types email...
        TextField("E-Mail", text: $viewModel.email)
    }
}
