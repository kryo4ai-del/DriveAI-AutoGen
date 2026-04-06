struct DashboardComplianceWidget: View {
    @ObservedObject var viewModel: ComplianceViewModel
    let daysUntilExam: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.green)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Deine Daten sind geschützt")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("\(viewModel.totalQuestionsProtected) Fragen gespeichert")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Exam proximity reassurance
            if daysUntilExam <= 7 {
                Text("Deine Daten sind sicher. Fokus: letzte Wiederholungen.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(12)
        .background(Color.green.opacity(0.1))
        .cornerRadius(10)
    }
}