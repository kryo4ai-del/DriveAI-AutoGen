import SwiftUI

struct ParentalConsentView: View {
    @StateObject var viewModel: ComplianceGateViewModel
    @State private var parentEmail: String = ""
    @State private var isEmailValid = true
    @FocusState private var isEmailFieldFocused: Bool

    var body: some View {
        VStack(spacing: 24) {
            headerView

            emailInputView

            if !isEmailValid {
                Text("Bitte gib eine gültige E-Mail-Adresse ein")
                    .foregroundStyle(.red)
                    .font(.caption)
                    .transition(.opacity)
            }

            Spacer()

            consentButton
        }
        .padding()
        .navigationTitle("Elternbestätigung")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground))
        .alert("Fehler", isPresented: Binding<Bool>(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.error ?? "Unbekannter Fehler")
        }
        .task {
            await viewModel.initializeCompliance()
        }
    }

    private var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "envelope.circle")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("Elternliche Zustimmung erforderlich")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text("Wir haben eine E-Mail an die von dir angegebene Adresse gesendet. Bitte bestätige die Zustimmung.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var emailInputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("E-Mail-Adresse der Eltern")
                .font(.headline)

            TextField("E-Mail-Adresse", text: $parentEmail)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($isEmailFieldFocused)
                .onChange(of: parentEmail) { newValue in
                    isEmailValid = isValidEmail(newValue)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isEmailValid ? Color.clear : Color.red, lineWidth: 1)
                )
        }
    }

    private var consentButton: some View {
        Button(action: {
            Task {
                await viewModel.submitParentalConsent(parentEmail: parentEmail)
            }
        }) {
            if viewModel.isLoading {
                ProgressView()
            } else {
                Text("Zustimmung bestätigen")
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.isLoading || !isEmailValid)
        .controlSize(.large)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}