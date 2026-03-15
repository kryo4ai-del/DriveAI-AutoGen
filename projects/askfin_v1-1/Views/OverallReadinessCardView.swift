struct OverallReadinessCardView: View {
    let snapshot: ExamReadinessSnapshot
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(Int(snapshot.overallReadinessPercentage))%")
                        .font(.system(size: 40, weight: .bold))
                        // ✅ Add accessibility label
                        .accessibilityLabel(Text("Overall readiness percentage"))
                        // ✅ Add value for screen readers
                        .accessibilityValue(
                            Text(
                                String(format: NSLocalizedString(
                                    "%d percent of exam readiness", 
                                    comment: "Accessibility value"
                                ), Int(snapshot.overallReadinessPercentage))
                            )
                        )
                    
                    Text("mastered")
                        .font(.caption)
                        .accessibilityHidden(true) // Redundant with parent
                }
                
                Spacer()
                
                // ✅ Replace canvas with accessible alternative
                CircularProgressAccessibleView(
                    percentage: snapshot.overallReadinessPercentage,
                    color: readinessColor
                )
                .accessibilityLabel(Text("Readiness progress indicator"))
                .accessibilityValue(
                    Text(String(format: NSLocalizedString(
                        "%.1f percent complete",
                        comment: "Progress accessibility"
                    ), snapshot.overallReadinessPercentage))
                )
            }
            
            // ✅ Semantic progress bar (better a11y than custom canvas)
            ProgressView(value: snapshot.overallReadinessPercentage / 100.0)
                .tint(readinessColor)
                .accessibilityLabel(Text("Readiness progress"))
                .accessibilityValue(
                    Text(String(format: NSLocalizedString(
                        "%.0f percent", 
                        comment: "Progress percentage"
                    ), snapshot.overallReadinessPercentage))
                )
        }
        .accessibilityElement(children: .combine) // ✅ Group related elements
    }
}