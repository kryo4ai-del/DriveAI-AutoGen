struct WeakTopicsCard: View {
    let topic: WeakTopicsViewModel.WeakTopic
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) { // ✅ Top-align for flexible height
                VStack(alignment: .leading, spacing: 4) {
                    Label(
                        topic.name,
                        systemImage: severityIcon
                    )
                    .font(.headline) // ✅ Inherits Dynamic Type automatically
                    .lineLimit(2) // ✅ Allow wrapping, not truncation
                    
                    Text("\(Int(topic.accuracy * 100))% Genauigkeit")
                        .font(.caption) // ✅ Still Dynamic Type–responsive
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // ✅ Conditional layout for very large text
                if sizeCategory <= .large {
                    ProgressRing(
                        progress: topic.accuracy,
                        size: 60,
                        label: topic.name
                    )
                } else {
                    // Show horizontal bar instead for accessibility sizes
                    ProgressView(
                        value: topic.accuracy,
                        label: {
                            Text("\(Int(topic.accuracy * 100))%")
                                .font(.caption)
                        }
                    )
                    .frame(height: 20)
                }
            }
            
            ProgressView(
                value: topic.accuracy,
                label: {
                    Text("Empfohlene Wiederholungen: \(topic.recommendedReviewCount)")
                        .font(.caption2) // ✅ Dynamic Type–aware
                }
            )
            .tint(severityColor)
            
            Button(action: {}) {
                Label("Jetzt wiederholen", systemImage: "arrow.right")
                    .font(.subheadline) // ✅ Scales with Dynamic Type
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44) // ✅ Maintain touch target even at XXL
            }
            .buttonStyle(.borderedProminent)
            .tint(severityColor)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}