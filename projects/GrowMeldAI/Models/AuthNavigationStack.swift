import SwiftUI
struct AuthNavigationStack: View {
    let viewModel: AuthViewModel
    @State private var showSignUp = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Accessible tab switcher
            Picker(selection: $showSignUp, label: Text("Authentifizierungsmodus")) {
                Text("Anmelden")
                    .tag(false)
                    .accessibilityLabel("Anmeldeformular")
                
                Text("Registrieren")
                    .tag(true)
                    .accessibilityLabel("Registrierungsformular")
            }
            .pickerStyle(.segmented)
            .accessibilityHint("Wechseln Sie zwischen Anmeldung und Registrierung")
            .padding()
            
            // Content
            Group {
                if showSignUp {
                    SignUpView()
                        .accessibilityElement(children: .combine)
                } else {
                    LoginView(viewModel: viewModel, showSignUp: $showSignUp)
                        .accessibilityLabel("Anmeldebildschirm")
                }
            }
            .transition(.opacity)
        }
    }
}