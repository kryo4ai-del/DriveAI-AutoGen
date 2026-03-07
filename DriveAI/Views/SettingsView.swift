struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        Form {
            Toggle("Notifications", isOn: $viewModel.notificationsEnabled)
            Picker("Language", selection: $viewModel.language) {
                Text("Deutsch").tag("Deutsch")
                Text("English").tag("English")
            }.pickerStyle(SegmentedPickerStyle())
            Toggle("Dark Mode", isOn: $viewModel.darkModeEnabled)
        }
        .navigationTitle("Settings")
    }
}