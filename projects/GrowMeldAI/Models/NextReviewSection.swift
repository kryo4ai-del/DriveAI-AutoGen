struct NextReviewSection: View {
    let questions: [Question]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nächste Überprüfung")
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(questions.prefix(3), id: \.id) { question in
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(question.category)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(question.text)
                                .font(.subheadline)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundStyle(.blue)
                    }
                    .padding(8)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Frage: \(question.text)")
                    .accessibilityHint("Kategorie: \(question.category)")
                }
            }
            
            if questions.count > 3 {
                NavigationLink(destination: NextReviewDetailScreen()) {
                    Text("Alle ansehen")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct NextReviewDetailScreen: View {
    var body: some View {
        Text("Next review questions")
    }
}