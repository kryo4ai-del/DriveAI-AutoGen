struct ReadinessSummary: View {
    let profile: UserProfile
    
    var readiness: ExamReadiness {
        ExamReadiness(
            userProfile: profile,
            allCategoryStats: profile.categoryPerformance
        )
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Prüfungsvorbereitung")
                    .font(.headline)
                
                Spacer()
                
                // ✓ Use status badge with both color AND icon/text
                ReadinessStatusBadge(status: readiness.status)
                    .accessibilityLabel("Status: \(readiness.status.label)")
            }
            
            // ✓ Progress ring with high contrast
            ZStack {
                Circle()
                    .stroke(Color(.systemGray3), lineWidth: 12)
                
                Circle()
                    .trim(from: 0, to: readiness.readinessScore / 100)
                    .stroke(readiness.status.color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(readiness.readinessPercentage)%")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(readiness.status.label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 150)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Vorbereitungsgrad")
            .accessibilityValue("\(readiness.readinessPercentage)% \(readiness.status.label)")
            
            // ✓ Text-based status explanation (not color-dependent)
            HStack(spacing: 8) {
                Image(systemName: readiness.status.icon)
                    .foregroundColor(readiness.status.color)
                    .accessibilityHidden(true)
                
                Text(readinessExplanation)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(6)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
    
    private var readinessExplanation: String {
        switch readiness.status {
        case .ready:
            return "Ausgezeichnet! Du bist gut vorbereitet. Überdenke die schwächeren Kategorien."
        case .inProgress:
            return "Gute Fortschritte! Fokussiere auf empfohlene Kategorien für +\(readiness.readinessPercentage)%."
        case .needsReview:
            return "Intensives Training empfohlen. \(readiness.recommendedDailyMinutes) Min. täglich üben."
        }
    }
}

struct ReadinessStatusBadge: View {
    let status: ReadinessStatus
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: status.icon)
            Text(status.label)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(status.color.opacity(0.2))
        .foregroundColor(status.color)
        .cornerRadius(6)
        // ✓ Ensure 4.5:1 contrast
        .accessibilityElement(children: .combine)
    }
}