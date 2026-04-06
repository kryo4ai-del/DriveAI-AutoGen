struct ConsentManagementScreen: View {
    @EnvironmentObject var consentManager: AppConsentManager
    
    var body: some View {
        List {
            Section("Erforderlich") {
                ConsentRow(
                    title: "Essentielle Cookies",
                    description: "Für App-Funktionalität",
                    isGranted: true,
                    isEditable: false
                )
            }
            
            Section("Optional") {
                ForEach(consentManager.optionalPreferences) { pref in
                    ConsentToggle(
                        preference: pref,
                        onToggle: { consentManager.updateConsent(pref.id, granted: $0) }
                    )
                }
            }
        }
        .navigationTitle("Datenschutz-Einstellungen")
    }
}