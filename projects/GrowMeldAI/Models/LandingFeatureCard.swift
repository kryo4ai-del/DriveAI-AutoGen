import SwiftUI

struct LandingFeatureCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon background
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(accentColor)
            }
            
            // Title
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            
            // Subtitle
            Text(subtitle)
                .font(.system(size: 13, weight: .regular))
                .lineLimit(3)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 140)
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    LandingFeatureCard(
        icon: "checkmark.circle.fill",
        title: "Offizielle Fragen",
        subtitle: "Aus dem TÜV-Katalog 2024",
        accentColor: .green
    )
}