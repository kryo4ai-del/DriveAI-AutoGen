struct ExamReadinessGaugeView: View {
    let data: ExamReadinessData
    @State private var isExpanded = false
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with proper semantics
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Strings.PerformanceTracking.examReadiness)
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("\(data.daysRemaining) \(Strings.PerformanceTracking.daysRemaining)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibilityHidden(true) // Redundant with readiness badge
                }
                
                Spacer()
                
                readinessBadge
            }
            .accessibilityElement(children: .combine)
            
            // Gauge (adaptive height for Dynamic Type)
            gaugeArcView
                .accessibilityLabel("Erfolgsquote Gauge")
                .accessibilityValue(gaugeAccessibilityValue)
                .accessibilityHint("Zeigt Ihren Fortschritt zur Prüfungsbereitschaft an")
            
            // Stats Row
            HStack(spacing: 16) {
                StatPillar(
                    label: Strings.PerformanceTracking.successRate,
                    value: "\(Int(data.overallSuccessRate * 100))%",
                    color: colorForSuccessRate(data.overallSuccessRate)
                )
                
                StatPillar(
                    label: Strings.PerformanceTracking.categoriesCompleted,
                    value: "\(data.categoriesCompleted)/\(data.totalCategories)",
                    color: .blue
                )
            }
            .accessibilityElement(children: .contain)
            
            // Expandable Details
            if isExpanded {
                detailsSection
                    .accessibilityElement(children: .contain)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(gaugeAccessibilityLabel)
        .accessibilityHint("Tippen zum \(isExpanded ? "Einklappen" : "Erweitern") der Details")
    }
    
    // MARK: - Dynamic Type Support
    private var gaugeHeight: CGFloat {
        switch sizeCategory {
        case .accessibilityExtraExtraExtraLarge:
            return 200
        case .accessibilityExtraExtraLarge:
            return 180
        case .accessibilityExtraLarge:
            return 160
        case .accessibilityLarge:
            return 150
        case .extraExtraExtraLarge:
            return 150
        default:
            return 140
        }
    }
    
    private var gaugeArcView: some View {
        ZStack {
            // Background arc
            Circle()
                .trim(from: 0.25, to: 0.75)
                .stroke(Color(.tertiarySystemBackground), lineWidth: 8)
            
            // Progress arc
            Circle()
                .trim(from: 0.25, to: 0.25 + (0.5 * progress))
                .stroke(
                    colorForSuccessRate(data.overallSuccessRate),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
            
            // Center text with Dynamic Type scaling
            VStack(spacing: 4) {
                Text("\(Int(data.overallSuccessRate * 100))")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                
                Text("%")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(height: gaugeHeight)
    }
    
    private var readinessBadge: some View {
        VStack(spacing: 2) {
            Image(systemName: data.readinessIcon)
                .font(.title2)
            
            Text(data.readinessLevel.rawValue)
                .font(.caption2)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(width: 70)
        .padding(8)
        .background(colorForReadinessLevel(data.readinessLevel).opacity(0.2))
        .cornerRadius(8)
        .foregroundColor(colorForReadinessLevel(data.readinessLevel))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Bereitschaftsstufe")
        .accessibilityValue(data.readinessLevel.rawValue)
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
                .accessibilityHidden(true)
            
            DetailRow(
                label: Strings.PerformanceTracking.questionsAnswered,
                value: "\(data.categoriesCompleted * 50)"
            )
            
            DetailRow(
                label: Strings.PerformanceTracking.readinessPercentage,
                value: "\(Int(data.overallSuccessRate * 100))%"
            )
            
            DetailRow(
                label: Strings.PerformanceTracking.nextSteps,
                value: nextStepsText
            )
        }
    }
    
    // MARK: - Accessibility Values
    private var gaugeAccessibilityLabel: String {
        "Prüfungsvorbereitung Status: \(data.readinessLevel.rawValue)"
    }
    
    private var gaugeAccessibilityValue: String {
        """
        Erfolgsquote: \(Int(data.overallSuccessRate * 100)) Prozent. \
        Kategorien: \(data.categoriesCompleted) von \(data.totalCategories) abgeschlossen. \
        \(data.daysRemaining) Tage bis zur Prüfung.
        """
    }
    
    private var progress: Double {
        Double(data.categoriesCompleted) / Double(data.totalCategories)
    }
    
    // ... rest of methods remain the same
}