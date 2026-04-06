// Views/CameraPermissionStateCard.swift
struct CameraPermissionStateCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let actionTitle: String?
    let onAction: (() -> Void)?
    let secondaryText: String?
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 0)
            }
            
            if let secondaryText = secondaryText {
                Text(secondaryText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if let actionTitle = actionTitle, let onAction = onAction {
                Button(action: onAction) {
                    Text(actionTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(iconColor)
            }
        }
        .padding(12)
        .background(iconColor.opacity(0.1))
        .cornerRadius(12)
        .accessibilityElement(children: .contain)
    }
}

// Usage:
CameraPermissionStateCard(
    icon: "exclamationmark.circle.fill",
    iconColor: .orange,
    title: "Kamera-Zugriff verweigert",
    description: "Bitte aktivieren Sie Kamera-Zugriff in den Einstellungen.",
    actionTitle: "Einstellungen öffnen",
    onAction: viewModel.openSettings,
    secondaryText: nil
)

CameraPermissionStateCard(
    icon: "lock.circle.fill",
    iconColor: .red,
    title: "Kamera-Zugriff eingeschränkt",
    description: "Ein Geräteverwalter hat Kamera-Zugriff eingeschränkt.",
    actionTitle: nil,
    onAction: nil,
    secondaryText: "Kontaktieren Sie Ihren Geräteverwalter."
)