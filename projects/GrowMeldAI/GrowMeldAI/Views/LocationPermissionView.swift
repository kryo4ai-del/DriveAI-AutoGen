// Sources/Features/Location/Views/LocationPermissionView.swift
import SwiftUI

struct LocationPermissionView: View {
    @StateObject var viewModel: LocationPermissionViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // HEADING – Accessible container
            VStack(spacing: 8) {
                Image(systemName: "location.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                    .accessibilityHidden(true)  // Decorative
                
                Text("Standort für Prüfstelle nutzen")
                    .font(.title2)
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)
                
                Text("Wir zeigen dir die nächste Prüfstelle und geschätzte Fahrtzeit.")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 24)
            
            // PERMISSION EXPLANATION – Critical for VoiceOver
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .accessibilityHidden(true)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Nur während App-Nutzung")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("Dein Standort wird nicht im Hintergrund verfolgt.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .accessibilityHidden(true)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Automatisch gelöscht")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("Dein Standort wird nach 30 Tagen automatisch gelöscht.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .accessibilityHidden(true)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Volle Kontrolle")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("Du kannst den Standortzugriff jederzeit deaktivieren.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            Spacer()
            
            // ACTION BUTTONS – 44x44pt minimum touch target
            VStack(spacing: 12) {
                Button(action: {
                    Task {
                        await viewModel.requestPermission()
                    }
                }) {
                    Text("Standort zulassen")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)  // ✅ 48pt > 44pt minimum
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .accessibilityLabel(Text("Standort zulassen"))
                .accessibilityHint(Text("Ermöglicht Zugriff auf deinen Standort zur Anzeige der nächsten Prüfstelle"))
                
                Button(action: { dismiss() }) {
                    Text("Später")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)  // ✅ 48pt > 44pt minimum
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }
                .accessibilityLabel(Text("Später"))
                .accessibilityHint(Text("Überspringt die Standortanfrage und zeigt sie später erneut"))
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        
        // ✅ Critical: Announce context BEFORE system permission dialog
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Standortanfrage"))
        .accessibilityValue(Text("DriveAI benötigt deinen Standort, um dir die nächste Fahrschule-Prüfstelle zu zeigen und deine Fahrtzeit zu schätzen. Dein Standort wird nach 30 Tagen automatisch gelöscht und ist unter deiner vollständigen Kontrolle."))
        
        // Show permission prompt AFTER context is announced
        .onAppear {
            // Small delay ensures VoiceOver announces the context first
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if viewModel.shouldShowPermissionRequest {
                    // System permission dialog presented here
                    Task {
                        await viewModel.requestPermission()
                    }
                }
            }
        }
    }
}