struct MaintenanceStatusCard: View {
    let item: MaintenanceItem
    let onRefreshTapped: () -> Void
    
    var accessibilityLabel: String {
        "\(item.categoryName), \(statusLabel)"
    }
    
    var accessibilityValue: String {
        "Genauigkeit: \(item.accuracy)%, \(daysText)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DriveAISpacing.md) {
            HStack(spacing: DriveAISpacing.md) {
                VStack(alignment: .leading, spacing: DriveAISpacing.xs) {
                    Text(item.categoryName)
                        .font(.system(.headline, design: .default))
                        .lineLimit(2)
                        .foregroundColor(.primary)
                        .accessibilityLabel("Kategorie: \(item.categoryName)")
                    
                    HStack(spacing: DriveAISpacing.sm) {
                        Image(systemName: statusIcon)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(statusColor)
                            .accessibilityHidden(true)  // Icon is decorative
                        
                        Text(statusLabel)
                            .font(.caption)
                            .foregroundColor(statusColor)
                            .accessibilityLabel("Status: \(statusLabel)")
                    }
                }
                
                Spacer()
                
                Image(systemName: "road.lanes")
                    .font(.system(size: 24))
                    .foregroundColor(statusColor.opacity(0.5))
                    .accessibilityHidden(true)  // Decorative
            }
            
            Divider()
                .accessibilityHidden(true)  // Decorative divider
            
            VStack(alignment: .leading, spacing: DriveAISpacing.xs) {
                HStack {
                    Text("Korrektheit:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibilityHidden(true)
                    
                    Spacer()
                    
                    Text("\(item.accuracy)%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .accessibilityLabel("Genauigkeit: \(item.accuracy) Prozent")
                }
                
                HStack {
                    Text("Empfohlen:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibilityHidden(true)
                    
                    Spacer()
                    
                    Text(daysText)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .accessibilityLabel(accessibilityDaysLabel)
                }
            }
            
            Button(action: onRefreshTapped) {
                HStack(spacing: DriveAISpacing.sm) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .semibold))
                        .accessibilityHidden(true)
                    
                    Text("Auffrischen")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DriveAISpacing.sm)
                .background(statusColor)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .accessibilityLabel("Auffrischen: \(item.categoryName)")
            .accessibilityHint("Startet ein 5-Fragen Quiz zur Auffrischung in \(item.categoryName)")
            .accessibilityAddTraits(.isButton)
        }
        .padding(DriveAISpacing.md)
        .background(DriveAIColors.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            statusColor.opacity(0.5),
                            statusColor.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .accessibilityHidden(true)
        )
        .shadow(color: statusColor.opacity(0.1), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .combine)  // Combine all child elements
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(accessibilityValue)
        .transition(.scale(scale: 0.95).combined(with: .opacity))
    }
    
    private var accessibilityDaysLabel: String {
        let days = item.daysSinceLastPractice
        if days == 0 {
            return "Heute geübt"
        } else if days == 1 {
            return "Gestern geübt"
        } else if days == Int.max {
            return "Noch nicht geübt"
        } else {
            return "Vor \(days) Tagen geübt"
        }
    }
}