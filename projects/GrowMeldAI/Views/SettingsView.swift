// Views/Screens/SettingsView.swift
struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        List {
            // Phase 1: Always present
            Section("Appearance") {
                Toggle("Dark Mode", isOn: $viewModel.darkModeEnabled)
            }
            
            // Phase 2: Only after legal clearance
            #if PHASE_2_APPROVED
            Section("Notifications") {
                NotificationPreferenceView()
                    .environmentObject(viewModel)
            }
            #endif
        }
    }
}

// ViewModels/SettingsViewModel.swift
class SettingsViewModel: ObservableObject {
    @Published var darkModeEnabled: Bool = false
    
    #if PHASE_2_APPROVED
    @Published var notificationPreferences: NotificationPreference?
    
    func loadNotificationPreferences() {
        notificationPreferences = notificationRepository.loadPreferences()
    }
    #endif
}