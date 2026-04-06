// Presentation/Views/Backup/BackupSettingsView.swift

import SwiftUI

struct BackupSettingsView: View {
    @EnvironmentObject var backupService: BackupDomainService
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        List {
            Section("Automatische Sicherung") {
                Toggle(isOn: $backupService.isBackupEnabled) {
                    Label {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Automatische Sicherung aktivieren")
                                .font(.body)
                                // ✅ Dynamic Type: scaledFont respects Dynamic Type
                                .lineLimit(nil)  // Allow wrapping
                            
                            Text("Sicherung wird täglich erstellt")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(nil)
                        }
                    } icon: {
                        Image(systemName: "icloud.and.arrow.up")
                            // ✅ Scale icon with text
                            .font(.system(.body, design: .default))
                    }
                }
                .accessibilityLabel("Automatische Sicherung")
                .accessibilityHint("Wenn aktiviert, wird täglich eine Sicherung erstellt")
                .accessibilityValue(backupService.isBackupEnabled ? "Aktiviert" : "Deaktiviert")
            }
            
            Section("Letzte Sicherung") {
                if let lastTime = backupService.lastBackupTime {
                    HStack {
                        Text("Zeitstempel")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(formatDate(lastTime))
                            // ✅ Dynamic Type: .lineLimit(nil) for wrapping
                            .lineLimit(nil)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Letzte Sicherung")
                    .accessibilityValue(formatAccessibilityDate(lastTime))
                } else {
                    Text("Noch keine Sicherung erstellt")
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                }
            }
            
            Section {
                Button(action: {
                    Task {
                        // Trigger manual backup
                    }
                }) {
                    HStack {
                        // ✅ Minimum touch target: 44x44pt
                        Image(systemName: "arrow.up.icloud")
                        Text("Jetzt sichern")
                            .lineLimit(nil)  // Wrap for large text
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)  // iOS HIG: 44pt minimum
                }
                .foregroundColor(.blue)
                .accessibilityLabel("Manuelle Sicherung erstellen")
                .accessibilityHint("Erstellt sofort eine Sicherung deines aktuellen Stands")
            }
            
            Section {
                Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Alle Daten löschen")
                            .lineLimit(nil)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)  // iOS HIG minimum
                }
                .accessibilityLabel("Alle Daten löschen")
                .accessibilityHint("Dies löscht permanent deine Sicherung und den Lernfortschritt")
                .accessibilityAddTraits(.isButton)
            }
        }
        .confirmationDialog(
            "Alle Daten wirklich löschen?",
            isPresented: $showDeleteConfirmation,
            actions: {
                Button("Löschen", role: .destructive) {
                    Task {
                        await backupService.deleteBackup()
                    }
                }
                Button("Abbrechen", role: .cancel) {}
            },
            message: {
                Text("Dies kann nicht rückgängig gemacht werden. Dein gesamter Lernfortschritt wird gelöscht.")
            }
        )
        .navigationTitle("Sicherung & Daten")
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatAccessibilityDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "EEEE, d. MMMM yyyy 'um' HH:mm 'Uhr'"
        return formatter.string(from: date)
    }
}