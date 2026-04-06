struct LocationDetailsSheet: View {
    @ObservedObject var permissionManager: LocationPermissionManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Status").accessibilityAddTraits(.isHeader)) {
                    DetailRow(
                        label: "Berechtigung",
                        value: statusDescription,
                        icon: statusIcon,
                        color: statusColor
                    )
                    
                    if let location = permissionManager.currentLocation {
                        DetailRow(
                            label: "Zuletzt aktualisiert",
                            value: location.timestamp.formatted(date: .abbreviated, time: .shortened),
                            icon: "clock.fill",
                            color: .blue
                        )
                    }
                }
                
                if permissionManager.permissionStatus == .denied {
                    Section {
                        Button(action: { permissionManager.openAppSettings() }) {
                            Label("Öffne Einstellungen", systemImage: "gear")
                        }
                        .accessibilityLabel("Öffne iOS-Einstellungen")
                    }
                }
            }
            .navigationTitle("Standortdetails")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") { dismiss() }
                        .accessibilityLabel("Schließe Standortdetails")
                }
            }
        }
    }
    
    private var statusDescription: String {
        switch permissionManager.permissionStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return "Aktiviert"
        case .denied:
            return "Abgelehnt"
        case .restricted:
            return "Eingeschränkt"
        case .notDetermined:
            return "Ausstehend"
        }
    }
    
    private var statusIcon: String {
        permissionManager.permissionStatus.isAuthorized ? "checkmark.circle.fill" : "xmark.circle.fill"
    }
    
    private var statusColor: Color {
        permissionManager.permissionStatus.isAuthorized ? .green : .red
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .accessibilityElement(children: .combine)
    }
}