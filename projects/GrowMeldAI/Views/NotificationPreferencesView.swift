struct NotificationPreferencesView: View {
    @StateObject var viewModel = NotificationSettingsViewModel()
    
    var body: some View {
        Form {
            Section(header: Text("Benachrichtigungen")) {
                Toggle(
                    "Lernimpulse aktivieren",
                    isOn: Binding(
                        get: { viewModel.consentManager.isConsentGranted },
                        set: { viewModel.toggleNotifications($0) }
                    )
                )
                .accessibilityLabel("Benachrichtigungen für Lernimpulse")
                .accessibilityHint(
                    "Schalte Benachrichtigungen ein oder aus. "
                    + "Diese können jederzeit geändert werden."
                )
            }
            
            if viewModel.notificationPreference.isEnabled {
                Section(header: Text("Einstellungen")) {
                    NavigationLink(destination: NotificationFrequencyView(viewModel: viewModel)) {
                        Label("Ruhezeiten", systemImage: "moon.zzz")
                    }
                }
            }
        }
        .navigationTitle("Benachrichtigungen")
    }
}