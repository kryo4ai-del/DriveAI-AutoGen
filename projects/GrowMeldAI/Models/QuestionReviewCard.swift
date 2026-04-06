// Ensure ALL interactive elements are ≥44x44pt
struct QuestionReviewCard: View {
    let item: SpacedRepetitionItem
    @State private var isSelected = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main card content
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.categoryName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(item.questionText)
                            .font(.body)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    // Difficulty badge — ensure ≥44x44pt
                    Button(action: {}) {
                        Text(item.difficulty.label)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                    }
                    .accessibilityLabel("Schwierigkeitsgrad: \(item.difficulty.label)")
                    .frame(minWidth: 44, minHeight: 44)  // ← Minimum touch target
                    .contentShape(Rectangle())  // Expands tap area
                }
                
                HStack(spacing: 12) {
                    // Urgency indicator
                    VStack(spacing: 2) {
                        Image(systemName: item.urgencyLevel.icon)
                            .foregroundColor(item.urgencyLevel.color)
                        
                        Text(item.urgencyLevel.label)
                            .font(.caption2)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(item.urgencyLevel.label)
                    .frame(minWidth: 44, minHeight: 44)
                    
                    Spacer()
                    
                    // Review count
                    VStack(spacing: 2) {
                        Text("\(item.reviewCount)")
                            .font(.caption)
                            .fontWeight(.bold)
                        
                        Text("Reviews")
                            .font(.caption2)
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }
            }
            .padding(12)
            
            // Selection indicator (≥44x44pt)
            Button(action: { isSelected.toggle() }) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .accessibilityLabel(isSelected ? "Abgewählt" : "Ausgewählt")
            .frame(width: 44, height: 44)
            .padding(8)
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
    }
}

// Filter buttons in queue screen
struct SpacedRepetitionQueueScreen: View {
    @StateObject private var viewModel = SpacedRepetitionViewModel()
    
    var body: some View {
        VStack {
            // Filter buttons — each ≥44x44pt
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(UrgencyLevel.allCases, id: \.self) { urgency in
                        Button(action: { viewModel.filterByUrgency(urgency) }) {
                            Text(urgency.label)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                        }
                        .accessibilityLabel("Filter nach: \(urgency.label)")
                        .frame(minHeight: 44)  // Minimum height
                        .background(viewModel.selectedUrgency == urgency ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(viewModel.selectedUrgency == urgency ? .white : .primary)
                        .cornerRadius(6)
                    }
                }
                .padding(.horizontal, 16)
            }
            
            // Queue list
            List(viewModel.filteredQueue) { item in
                NavigationLink(destination: QuestionDetailView(item: item)) {
                    QuestionReviewCard(item: item)
                }
                .frame(minHeight: 44)
            }
        }
    }
}