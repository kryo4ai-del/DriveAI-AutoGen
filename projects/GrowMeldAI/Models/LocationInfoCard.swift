import SwiftUI
import CoreLocation
struct LocationInfoCard: View {
    let distance: CLLocationDistance?
    let examCenterName: String = "Prüfungszentrum"
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Entfernung zum Prüfungszentrum")
                .font(.headline)
                .accessibilityLabel("Entfernung zum Prüfungszentrum")
            
            if let distance = distance {
                let formattedDistance = formatDistance(distance)
                
                VStack(spacing: 4) {
                    Text(formattedDistance)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.blue)
                    
                    Text("km")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Entfernung")
                .accessibilityValue("\(formattedDistance) Kilometer")
                .accessibilityHint("Die ungefähre Entfernung zwischen deinem aktuellen Standort und dem Prüfungszentrum.")
            } else {
                VStack(spacing: 4) {
                    Text("—")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.secondary)
                    
                    Text("Standort nicht verfügbar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Entfernung nicht verfügbar")
                .accessibilityValue("Bitte aktiviere Standortzugriff, um die Entfernung zu sehen.")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .accessibilityElement(children: .contain)  // Treat as single unit
    }
    
    private func formatDistance(_ distance: CLLocationDistance) -> String {
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f", distance / 1000)
        }
    }
}