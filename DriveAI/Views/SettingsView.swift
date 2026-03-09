import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        Form {
            // MARK: - App preferences

            Section("Preferences") {
                Toggle("Notifications", isOn: $viewModel.notificationsEnabled)

                Picker("Language", selection: $viewModel.language) {
                    Text("Deutsch").tag("Deutsch")
                    Text("English").tag("English")
                }
                .pickerStyle(.segmented)

                Toggle("Dark Mode", isOn: $viewModel.darkModeEnabled)
            }

            // MARK: - Developer tools

            Section("Developer") {
                NavigationLink(destination: SampleValidationView()) {
                    Label("Sample Validation", systemImage: "checklist")
                }
                NavigationLink(destination: AnalysisDebugPanel()) {
                    Label("Debug Panel", systemImage: "ladybug.fill")
                }
            }
        }
        .navigationTitle("Settings")
    }
}
