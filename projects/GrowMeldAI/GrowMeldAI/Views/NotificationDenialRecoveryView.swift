// Views/Onboarding/NotificationDenialRecoveryView.swift

struct NotificationDenialRecoveryView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "bell.slash")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary)
                
                Text("Benachrichtigungen deaktiviert")
                    .font(.headline)
                
                Text("Du kannst Benachrichtigungen später in den Einstellungen aktivieren.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: { openSettings() }) {
                    Text("In Einstellungen aktivieren")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: { Task { await viewModel.proceedToNextStep() } }) {
                    Text("Weiter")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
            }
        }
        .padding(20)
    }
    
    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}