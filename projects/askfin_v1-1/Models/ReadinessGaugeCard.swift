struct ReadinessGaugeCard: View {
    let readiness: ExamReadiness
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress to Exam-Ready")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray5))
                    .frame(height: 12)
                
                Capsule()
                    .fill(progressColor)
                    .frame(width: CGFloat(readiness.overallReadinessScore) * 200, height: 12)
            }
            .frame(width: 200)
            .accessibilityElement(children: .ignore)
            .accessibility(label: Text("Readiness progress"))
            .accessibility(value: Text("\(Int(readiness.overallReadinessScore * 100))% complete"))
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var progressColor: Color {
        let score = readiness.overallReadinessScore
        if score >= 0.75 { return .green }
        if score >= 0.5 { return .orange }
        return .red
    }
}