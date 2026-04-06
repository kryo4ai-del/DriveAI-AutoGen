struct ExamReadinessHeaderView: View {
    let score: Double       // 0.0 - 5.0
    let coverage: Double    // 0.0 - 1.0
    let message: String
    
    @State private var isShimmering = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var starRating: Int {
        Int(score)
    }
    
    var coveragePercent: Int {
        Int(coverage * 100)
    }
    
    var messageColor: Color {
        switch score {
        case 4.5...:
            return DriveAIColors.maintenanceActive
        case 3.0..<4.5:
            return DriveAIColors.maintenanceNeeded
        default:
            return DriveAIColors.maintenanceDormant
        }
    }
    
    var body: some View {
        VStack(spacing: DriveAISpacing.md) {
            // Star Rating with VoiceOver context
            HStack(spacing: DriveAISpacing.sm) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: index < starRating ? "star.fill" : "star")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(messageColor)
                        .accessibilityHidden(true)  // Stars are decorative; label below provides meaning
                }
                Spacer()
            }
            // Accessibility: Announce the rating once for the group
            .accessibilityLabel("Bewertung: \(starRating) von 5 Sternen")
            
            // Message Section
            VStack(alignment: .leading, spacing: DriveAISpacing.sm) {
                Text("Theorieprüfungs-Reife")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibilityLabel("Theorieprüfungs-Reife")
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .accessibilityLabel(message)  // User-facing message is already descriptive
            }
            
            // Progress Bar with Accessible Value
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    DriveAIColors.maintenanceDormant.opacity(0.3),
                                    DriveAIColors.maintenanceDormant.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .accessibilityHidden(true)
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    DriveAIColors.maintenanceActive,
                                    DriveAIColors.maintenanceActive.opacity(0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: geometry.size.width * coverage)
                        .animation(.easeInOut(duration: DriveAIAnimation.standard), value: coverage)
                        .accessibilityHidden(true)  // Redundant with label below
                    
                    // Shimmer (reduced motion aware)
                    if coverage > 0.7 && !reduceMotion {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.0),
                                        Color.white.opacity(0.2),
                                        Color.white.opacity(0.0)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: geometry.size.width * coverage)
                            .offset(x: isShimmering ? geometry.size.width : -geometry.size.width)
                            .animation(
                                Animation.linear(duration: 2).repeatForever(autoreverses: false),
                                value: isShimmering
                            )
                            .accessibilityHidden(true)
                    }
                }
            }
            .frame(height: 12)
            .accessibilityLabel("Fortschritt: \(coveragePercent) Prozent")
            .accessibilityValue("\(coveragePercent)%")
        }
        .padding(.horizontal, DriveAISpacing.lg)
        .padding(.vertical, DriveAISpacing.md)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    DriveAIColors.cardBackground,
                    DriveAIColors.cardBackground.opacity(0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .padding(.horizontal, DriveAISpacing.lg)
        .padding(.top, DriveAISpacing.lg)
        .onAppear {
            if coverage > 0.7 && !reduceMotion {
                isShimmering = true
            }
        }
        .onDisappear {
            isShimmering = false  // Cleanup animation
        }
    }
}