struct MilestoneProgress: View {
    let completed: Int
    let total: Int
    
    var milestones: [(threshold: Double, label: String)] {
        [
            (0.25, "Foundation (25%)"),
            (0.50, "Competent (50%)"),
            (0.75, "Expert (75%)"),
            (1.0, "Mastery")
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(milestones, id: \.label) { milestone in
                HStack {
                    if Double(completed) / Double(total) >= milestone.threshold {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(.gray)
                    }
                    Text(milestone.label)
                        .font(.body)
                        .opacity(Double(completed) / Double(total) >= milestone.threshold ? 1 : 0.6)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Learning milestones")
        .accessibilityValue("\(completed) of \(total) questions answered")
    }
}