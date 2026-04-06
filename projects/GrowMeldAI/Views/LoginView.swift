import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var email: String = ""
}

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        TextField("E-Mail", text: $viewModel.email)
    }
}