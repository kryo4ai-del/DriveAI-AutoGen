// Presentation/Views/Backup/BackupStatusView.swift

import SwiftUI

struct BackupStatusView: View {
    @EnvironmentObject var backupService: BackupDomainService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Last Backup Time Display
            HStack {
                Label("Letzte Sicherung", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
                
                Spacer()
                
                if let lastTime = backupService.lastBackupTime {
                    Text(lastTime, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("Zeitstempel der letzten Sicherung")
                        .accessibilityValue(formatAccessibilityDate(lastTime))
                } else {
                    Text("Keine Sicherung vorhanden")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("Backup-Status")
                        .accessibilityValue("Keine Sicherung vorhanden")
                }
            }
            .accessibilityElement(children: .combine)
            
            // Backup Now Button
            Button(action: {
                Task {
                    await backupService.createBackup(from: userData)
                }
            }) {
                HStack {
                    Image(systemName: "icloud.and.arrow.up")
                    Text("Jetzt Sichern")
                    
                    if backupService.backupStatus.isInProgress {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(backupService.backupStatus.isInProgress)
            // ✅ ACCESSIBILITY: Proper labels and hints
            .accessibilityLabel("Sicherung erstellen")
            .accessibilityHint("Erstellt eine Sicherung deines aktuellen Lernfortschritts und speichert sie auf diesem Gerät")
            .accessibilityAddTraits(.isButton)
            .accessibilityRemoveTraits(.isImage)
            
            // Status Messages (Toast-like)
            if case .failed(let error) = backupService.backupStatus {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                    Text(error.errorDescription ?? "Fehler")
                        .font(.callout)
                }
                .accessibilityLabel("Fehler bei der Sicherung")
                .accessibilityValue(error.errorDescription ?? "Unbekannter Fehler")
                // ✅ CRITICAL: Error messages must be announced to VoiceOver
                .onAppear {
                    UIAccessibility.post(notification: .announcement, argument: error.errorDescription)
                }
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatAccessibilityDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}