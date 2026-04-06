import SwiftUI
import Foundation
struct PurchaseConsentView: View {
    @State var consentGiven = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Bestätigung erforderlich")
                .font(.headline)
            
            Text("""
            Um dieses Premium-Feature freizuschalten, speichern wir:
            • Ihr Kaufdatum und die gekaufte Funktion
            • Die Transaktion mit Apple
            • Ihren Entsperrungsstatus für zukünftige App-Nutzungen
            
            Ihre Daten werden für 7 Jahre aufbewahrt (steuerlich erforderlich).
            
            Erfahren Sie mehr in unserer Datenschutzrichtlinie.
            """)
            .font(.body)
            
            Toggle("Ich stimme zu", isOn: $consentGiven)
            
            Button("Fortfahren") { /* purchase */ }
                .disabled(!consentGiven)
        }
        .padding()
    }
}