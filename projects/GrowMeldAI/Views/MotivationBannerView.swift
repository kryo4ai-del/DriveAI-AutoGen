// After user answers a question, update daily progress:
struct MotivationBannerView: View {
    @ObservedObject var quotaManager: QuotaManager
    @ObservedObject var learningAnalytics: LearningAnalyticsManager  // NEW
    
    var body: some View {
        if let daily = quotaManager.dailyUsage {
            VStack(alignment: .leading, spacing: 8) {
                // Existing quota display
                HStack {
                    Image(systemName: motivationIcon)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(motivationTitle)
                        Text(motivationMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // ✅ NEW: Learning trajectory feedback
                if let forecast = learningAnalytics.readinessForecast {
                    Divider()
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Prüfungsbereitschaft")
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            ProgressView(value: forecast.currentReadiness)
                                .tint(readinessColor(forecast.currentReadiness))
                            
                            Text(
                                String(
                                    format: NSLocalizedString(
                                        "analytics.forecast",
                                        value: "Auf Kurs: %@ Tage bis zum Prüfungsziel",
                                        comment: "Days until exam goal achieved"
                                    ),
                                    forecast.daysUntilReadiness
                                )
                            )
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Visual indicator: on-track/warning/at-risk
                        StatusBadge(status: forecast.status)
                    }
                }
            }
            .padding()
            .background(bannerBackground)
            .cornerRadius(10)
        }
    }
}

// Expected data model:
struct ReadinessForecast {
    let currentReadiness: Double  // 0.0 to 1.0 based on category performance
    let daysUntilReadiness: Int   // Projected days at current pace
    let status: ForecastStatus    // .onTrack, .slipping, .accelerating
}

enum ForecastStatus {
    case onTrack          // 80%+ readiness by exam date
    case slipping         // 60-79% readiness
    case atRisk           // <60% readiness
}