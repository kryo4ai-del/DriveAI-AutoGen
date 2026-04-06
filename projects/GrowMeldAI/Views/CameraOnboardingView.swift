import SwiftUI

// 1. ONBOARDING: Opt-in to camera feature
struct CameraOnboardingView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Image("camera_hero")
                .resizable()
                .scaledToFit()
            
            Text("Dein Fahrschul-Superheld: Starte mit der Kamera")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Erkenne Verkehrszeichen in Echtzeit und lerne direkt aus deiner Umgebung.")
                .font(.body)
                .foregroundColor(.gray)
            
            Button(action: { 
                UserDefaults.standard.set(true, forKey: "camera_consent_given")
                dismiss() 
            }) {
                Text("Kamera-Zeichenerkennung starten")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Button(action: { dismiss() }) {
                Text("Lieber später") // Skip option
                    .foregroundColor(.blue)
            }
            
            Text("Bilder werden lokal verarbeitet und nicht gespeichert")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

// 2. SETTINGS: Manage consent + delete history
struct CameraSettingsView: View {
    @State private var cameraEnabled: Bool = UserDefaults.standard.bool(forKey: "camera_enabled")
    
    var body: some View {
        Form {
            Section("Kamera-Zeichenerkennung") {
                Toggle("Aktiviert", isOn: $cameraEnabled)
                    .onChange(of: cameraEnabled) { newValue in
                        UserDefaults.standard.set(newValue, forKey: "camera_enabled")
                    }
            }
            
            Section("Datenschutz") {
                Button(role: .destructive, action: {
                    // recognitionService.deleteAllRecognitionResults()
                }) {
                    Text("Erkennungsverlauf löschen")
                }
            }
        }
    }
}