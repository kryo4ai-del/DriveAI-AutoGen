import SwiftUI

struct FallbackStatusBadge: View {
    let isActive: Bool
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        if isActive {
            HStack(spacing: 6) {
                Image(systemName: "wifi.slash")
                    .accessibilityHidden(true)
                
                Text("Offline-Modus")
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.orange)
            .cornerRadius(6)
            .accessibilityLabel("Offline-Modus aktiv")
            .accessibilityHint("Die App funktioniert ohne Internetverbindung. Alle Fragen werden korrekt bewertet.")
            .accessibilityAddTraits(.isStaticText)
            .transition(
                reduceMotion ? .opacity : .asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .opacity
                )
            )
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        FallbackStatusBadge(isActive: true)
        FallbackStatusBadge(isActive: false)
    }
    .padding()
}