struct ProfileScreen: View {
    @EnvironmentObject var backupService: BackupDomainService
    
    var body: some View {
        List {
            Section("Exam Info") {
                // existing...
            }
            
            Section("Backup & Data") {
                BackupStatusView()  // Shows last backup time, "Backup Now" button
                Toggle("Auto-backup", isOn: $backupService.isBackupEnabled)
                Button("Restore from Backup") { 
                    showRestoreFlow = true 
                }
                Button("Delete All Data", role: .destructive) { 
                    showDeleteConfirmation = true 
                }
            }
        }
    }
}