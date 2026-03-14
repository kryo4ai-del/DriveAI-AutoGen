import SwiftUI

struct ActionButtonGroup: View {
    let result: SimulationResult
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 12) {
            // Primary: Retry
            NavigationLink(destination: Text("Quiz Retry")) {
                Label("Nochmal üben", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
            
            // Secondary: Home
            Button(action: { dismiss() }) {
                Label("Zur Startseite", systemImage: "house")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundStyle(.primary)
                    .cornerRadius(12)
            }
            
            // Tertiary: View Profile
            NavigationLink(destination: Text("Profile")) {
                Label("Profil ansehen", systemImage: "person.crop.circle")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundStyle(.primary)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}