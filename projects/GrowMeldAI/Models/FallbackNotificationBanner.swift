import SwiftUI

struct FallbackNotificationBanner: View {
    @Binding var isVisible: Bool
    let onDismiss: () -> Void
    
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var hasAppeared = false
    
    var body: some View {
        if isVisible {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "wifi.slash")
                        .font(.headline)
                        .foregroundColor(.orange)
                        .accessibilityHidden(true)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Offline-Modus aktiviert")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Die App funktioniert ohne Internetverbindung. Alle Fragen werden weiterhin korrekt bewertet.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                            .minimumScaleFactor(0.9)
                    }
                    
                    Spacer()
                    
                    Button(action: dismissBanner) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(Circle())
                    }
                    .accessibilityLabel("Benachrichtigung schließen")
                    .accessibilityHint("Schließt die Offline-Modus-Benachrichtigung")
                }
                .padding(12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemYellow).opacity(0.15))
            .border(Color.orange, width: 1)
            .cornerRadius(8)
            .padding()
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Benachrichtigung: Offline-Modus")
            .accessibilityAddTraits(.isHeader)
            .transition(
                reduceMotion ? .opacity : .asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .opacity
                )
            )
            .onAppear {
                hasAppeared = true
            }
            .onChange(of: hasAppeared) { _, newValue in
                if newValue {
                    postAccessibilityAnnouncement()
                }
            }
        }
    }
    
    private func dismissBanner() {
        let animationDuration = reduceMotion ? 0.0 : 0.2
        
        withAnimation(reduceMotion ? nil : .easeInOut(duration: animationDuration)) {
            isVisible = false
        }
        
        // Restore focus after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + 0.1) {
            UIAccessibility.post(notification: .layoutChanged, argument: nil)
        }
        
        onDismiss()
    }
    
    private func postAccessibilityAnnouncement() {
        // Delay to ensure view is fully rendered in accessibility tree
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            AccessibilityNotification.Announcement(
                "Offline-Modus aktiviert. Die App funktioniert ohne Internetverbindung. Alle Fragen werden korrekt bewertet."
            ).post()
        }
    }
}

#Preview {
    VStack {
        FallbackNotificationBanner(
            isVisible: .constant(true),
            onDismiss: {}
        )
        Spacer()
    }
    .background(Color(.systemBackground))
}