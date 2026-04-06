struct PrivacySettingsView: View {
  @StateObject var consentManager = ConsentManager()
  @State var showDeleteConfirmation = false
  
  var body: some View {
    List {
      Section("Datenfreigabe") {
        Toggle("Personalisierte Anzeigen", isOn: .init(
          get: { consentManager.isConsentGranted },
          set: { _ in /* toggle logic */ }
        ))
        
        Text("Hilft uns, dir relevante Inhalte zu zeigen.")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      
      Section("Datenschutz") {
        Link("Meta Werbeeinstellungen", destination: URL(string: "https://www.facebook.com/ads/preferences")!)
        
        Button(action: { showDeleteConfirmation = true }) {
          Text("Meine Daten löschen")
            .foregroundColor(.red)
        }
      }
    }
    .navigationTitle("Datenschutz")
    .alert("Bestätigung", isPresented: $showDeleteConfirmation) {
      Button("Löschen", role: .destructive) {
        Task { await consentManager.deleteAllData() }
      }
    }
  }
}