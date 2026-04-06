struct ReminderSettingsView: View {
    @StateObject private var viewModel: ReminderViewModel
    @State private var showTimePicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            headerSection
            
            // Toggle Section
            toggleSection
            
            // Time Picker Section
            if viewModel.isEnabled {
                timePickerSection
            }
            
            // Error Banner
            if let error = viewModel.errorMessage {
                errorBanner(error)
            }
            
            // Permission Info
            if viewModel.authorizationStatus != .authorized {
                permissionInfoBanner
            }
            
            Spacer()
        }
        .padding()
        .disabled(viewModel.isLoading)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Tägliche Erinnerungen", systemImage: "bell.fill")
                .font(.headline)
            Text("Bleibe motiviert und lerne jeden Tag für deinen Führerschein.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var toggleSection: some View {
        HStack {
            Toggle("Erinnerungen aktivieren", isOn: $viewModel.isEnabled)
                .onChange(of: viewModel.isEnabled) { oldValue, newValue in
                    Task {
                        await viewModel.toggleReminder(newValue)
                    }
                }
            
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
    }
    
    private var timePickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Erinnerungszeit")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                // Hour Picker
                VStack(alignment: .leading) {
                    Text("Stunde")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Picker("Stunde", selection: $viewModel.reminderHour) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text(String(format: "%02d", hour))
                                .tag(hour)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxHeight: 150)
                }
                
                // Minute Picker
                VStack(alignment: .leading) {
                    Text("Minute")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Picker("Minute", selection: $viewModel.reminderMinute) {
                        ForEach(stride(from: 0, to: 60, by: 5), id: \.self) { minute in
                            Text(String(format: "%02d", minute))
                                .tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxHeight: 150)
                }
            }
            
            Button(action: {
                Task {
                    await viewModel.updateReminderTime(
                        hour: viewModel.reminderHour,
                        minute: viewModel.reminderMinute
                    )
                }
            }) {
                Text("Zeit speichern")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
            VStack(alignment: .leading, spacing: 4) {
                Text("Fehler")
                    .font(.caption)
                    .fontWeight(.semibold)
                Text(message)
                    .font(.caption2)
            }
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var permissionInfoBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.slash.fill")
                .foregroundColor(.orange)
            VStack(alignment: .leading, spacing: 4) {
                Text("Benachrichtigungen erforderlich")
                    .font(.caption)
                    .fontWeight(.semibold)
                Text("Aktivieren Sie Benachrichtigungen in Einstellungen.")
                    .font(.caption2)
            }
            Spacer()
            Button("Einstellungen") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.caption)
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    let mockNotificationService = MockNotificationService()
    let mockPreferencesService = MockUserPreferencesService()
    
    return ReminderSettingsView(
        notificationService: mockNotificationService,
        preferencesService: mockPreferencesService
    )
}