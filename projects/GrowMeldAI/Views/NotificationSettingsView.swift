import SwiftUI

/// Settings screen to manage push notification preferences
struct NotificationSettingsView: View {
    @StateObject private var viewModel = NotificationSettingsViewModel()
    
    var body: some View {
        List {
            Section("Benachrichtigungen") {
                Toggle("Aktiviert", isOn: $viewModel.isEnabled)
            }
            
            Section("Benachrichtigungstypen") {
                ForEach(viewModel.triggers, id: \.identifier) { trigger in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(trigger.headline)
                                .font(.body)
                            Text(trigger.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if viewModel.isConsentGranted(for: trigger) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Button("Aktivieren") {
                                viewModel.resetConsent(for: trigger)
                            }
                            .font(.caption)
                        }
                    }
                }
            }
            
            Section("Datenschutz") {
                Button(role: .destructive) {
                    viewModel.deleteAllConsents()
                } label: {
                    Text("Alle Benachrichtigungen zurücksetzen")
                }
            }
        }
        .navigationTitle("Benachrichtigungen")
    }
}