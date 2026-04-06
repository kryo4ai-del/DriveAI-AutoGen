// Sources/Features/Location/Views/LocationStatusIndicator.swift
import SwiftUI

struct LocationStatusIndicator: View {
    @StateObject var viewModel: LocationPermissionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Status Icon
                Image(systemName: statusIconName)
                    .font(.title2)
                    .foregroundColor(statusColor)
                    .accessibilityHidden(true)  // Icon is decorative; text conveys meaning
                
                // Status Text
                VStack(alignment: .leading, spacing: 4) {
                    Text("Standortzugriff")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text(statusText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Settings Link or Button
                if viewModel.permissionStatus == .denied {
                    Button(action: {
                        viewModel.openSettings()
                    }) {
                        Image(systemName: "gear")
                            .font(.body)
                            .padding(8)
                            .frame(minWidth: 44, minHeight: 44)  // ✅ Touch target
                    }
                    .accessibilityLabel(Text("Einstellungen öffnen"))
                    .accessibilityHint(Text("Öffnet Einstellungen, um Standortzugriff zu aktivieren"))
                } else {
                    Toggle("", isOn: $viewModel.locationEnabled)
                        .frame(width: 50)  // Standard toggle is 51pt wide, accessible
                        .accessibilityLabel(Text("Standortzugriff"))
                        .accessibilityHint(Text("Schaltet den Standortzugriff für DriveAI um"))
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Privacy Note
            Text("Dein Standort wird nach 30 Tagen automatisch gelöscht.")
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityLabel(Text("Datenschutzhinweis"))
                .accessibilityValue(Text("Standortdaten werden nach 30 Tagen automatisch gelöscht"))
        }
        .padding(.vertical, 12)
    }
    
    // MARK: - Computed Properties
    
    private var statusIconName: String {
        switch viewModel.permissionStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return "location.fill"
        case .denied, .restricted:
            return "location.slash"
        case .notDetermined:
            return "location"
        }
    }
    
    private var statusColor: Color {
        switch viewModel.permissionStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return .green
        case .denied, .restricted:
            return .red
        case .notDetermined:
            return .gray
        }
    }
    
    private var statusText: String {
        switch viewModel.permissionStatus {
        case .authorizedWhenInUse:
            return "Aktiviert – Dein Standort wird zur Anzeige der nächsten Prüfstelle genutzt"
        case .authorizedAlways:
            return "Aktiviert (immer)"
        case .denied:
            return "Deaktiviert – Aktiviere in Einstellungen"
        case .restricted:
            return "Eingeschränkt durch Eltern-/Jugendschutz"
        case .notDetermined:
            return "Nicht konfiguriert"
        }
    }
}