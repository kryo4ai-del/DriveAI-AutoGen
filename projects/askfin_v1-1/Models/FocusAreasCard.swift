struct FocusAreasCard: View {
    let readiness: ExamReadiness
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Areas to Focus On", systemImage: "target")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(readiness.recommendedFocusCategories.prefix(3), id: \.self) { categoryID in
                    if let category = readiness.categoryScores[categoryID] {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.orange)
                            Text(category.categoryName)
                                .font(.body)
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}