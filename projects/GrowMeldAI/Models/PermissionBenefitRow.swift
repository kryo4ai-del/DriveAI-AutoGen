import SwiftUI
struct PermissionBenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
                .accessibilityHidden(true)  // Icon is decorative
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)  // Improved contrast
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
        .accessibilityElement(children: .ignore)  // CRITICAL: Combine all
        .accessibilityLabel(title)  // VoiceOver reads: "Regionale Statistiken"
        .accessibilityValue(description)  // VoiceOver reads on swipe: "Sehe deinen Fortschritt..."
    }
}