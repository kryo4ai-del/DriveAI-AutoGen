// Views/ExamReadinessCard.swift
struct ExamReadinessCard: View {
    let readiness: ExamReadiness?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Prüfungsbereitschaft")
                    .font(.headline)
                Spacer()
                if let readiness {
                    Text("\(Int(readiness.overallScore))%")
                        .font(.headline)
                        .foregroundColor(readiness.isReady ? .green : .orange)
                }
            }
            
            if let readiness {
                ProgressView(value: readiness.overallScore / 100)
                    .tint(readiness.isReady ? .green : .orange)
                
                Text(readiness.readinessLevel.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ProgressView()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}