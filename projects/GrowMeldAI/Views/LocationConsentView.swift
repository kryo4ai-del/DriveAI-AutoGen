import SwiftUI
// Views/LocationConsentView.swift
struct LocationConsentView: View {
    @ObservedObject var viewModel: LocationConsentViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with icon
            Image(systemName: "location.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.accentColor)
            
            // Purpose: learner-focused, German
            Text("Prüfungszentren in Ihrer Nähe")
                .font(.headline)
            
            Text("Mit Ihrem Standort zeigen wir verfügbare Prüfungstermine bei TÜV und Dekra in Ihrer Nähe. So finden Sie schnell einen Termin.")
                .font(.body)
                .foregroundColor(.secondary)
            
            // Privacy guarantee
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "lock.fill")
                    Text("Ihr Standort wird nicht gespeichert und nicht geteilt.")
                        .font(.caption)
                }
                HStack {
                    Image(systemName: "clock.fill")
                    Text("Wir verwenden ihn nur 5 Minuten lang zur Suche.")
                        .font(.caption)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            Spacer()
            
            // Actions
            VStack(spacing: 12) {
                Button(action: { viewModel.allowLocationAccess() }) {
                    Text("Standort freigeben")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: { viewModel.denyAndUsePostalCode() }) {
                    Text("Ohne Standort mit Postleitzahl suchen")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            
            // Link to Privacy Policy
            Link(destination: URL(string: "https://driveai.app/datenschutz")!) {
                Text("Datenschutzerklärung")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}