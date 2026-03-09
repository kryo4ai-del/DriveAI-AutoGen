import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var developerMode = AppConfig.isDeveloperMode
    @EnvironmentObject private var onboardingVM: OnboardingViewModel

    var body: some View {
        Form {

            // MARK: Preferences

            Section("Preferences") {
                Toggle("Notifications", isOn: $viewModel.notificationsEnabled)

                Picker("Language", selection: $viewModel.language) {
                    Text("Deutsch").tag("Deutsch")
                    Text("English").tag("English")
                }
                .pickerStyle(.segmented)

                Toggle("Dark Mode", isOn: $viewModel.darkModeEnabled)
            }

            // MARK: Developer

            Section {
                Toggle("Developer Mode", isOn: Binding(
                    get: { developerMode },
                    set: { developerMode = $0; AppConfig.isDeveloperMode = $0 }
                ))

                if developerMode {
                    NavigationLink(destination: SampleValidationView()) {
                        Label("Sample Validation", systemImage: "checklist")
                    }
                    NavigationLink(destination: AnalysisDebugPanel()) {
                        Label("Debug Panel", systemImage: "ladybug.fill")
                    }
                    resetOnboardingButton
                }
            } header: {
                Text("Developer")
            } footer: {
                if !developerMode {
                    Text("Enable to access validation and debug tools.")
                }
            }
        }
        .navigationTitle("Settings")
    }

    private var resetOnboardingButton: some View {
        Button(role: .destructive) {
            onboardingVM.resetOnboarding()
        } label: {
            Label("Reset Onboarding", systemImage: "arrow.counterclockwise")
        }
    }
}
