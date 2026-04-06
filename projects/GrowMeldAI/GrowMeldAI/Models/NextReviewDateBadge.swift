struct NextReviewDateBadge: View {
    let nextReviewDate: Date
    @State private var showEducationalHint = false
    
    var displayText: String {
        DateHelper.reviewTimingLabel(for: nextReviewDate)
    }
    
    var body: some View {
        Label(displayText, systemImage: isOverdue ? "exclamationmark.circle.fill" : "calendar")
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(isOverdue ? .red : .blue)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(isOverdue ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
            .cornerRadius(8)
            .onTapGesture {
                showEducationalHint.toggle()
            }
            // ✅ Show learning principle behind spacing
            .popover(isPresented: $showEducationalHint) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Wissenschaftlich optimiert")
                        .font(.caption)
                        .fontWeight(.bold)
                    Text("Diese Fragen wurden zum Zeitpunkt der "
                        + "maximalen Vergessenskurve geplant. "
                        + "Das verhindert, dass du es vergisst.")
                        .font(.caption2)
                        .lineLimit(3)
                }
                .padding()
                .frame(maxWidth: 200)
            }
    }
}