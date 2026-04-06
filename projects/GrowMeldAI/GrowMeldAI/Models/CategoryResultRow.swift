// Complete ResultScreen structure with full accessibility hierarchy

VStack(spacing: 24) {
    // ✓ Summary Section (accessible element grouping)
    VStack(spacing: 12) {
        Text(result.passed ? "PASSED ✓" : "FAILED ✗")
            .font(.title, weight: .bold)
            .foregroundColor(result.passed ? .green : .red)
        
        VStack(spacing: 4) {
            Text("\(result.correctAnswers) of 30 correct")
                .font(.headline)
                .accessibilityLabel("Your score")
                .accessibilityValue("\(result.correctAnswers) out of 30 correct answers")
            
            Text("\(Int(result.percentage))%")
                .font(.body)
                .foregroundColor(.secondary)
                .accessibilityHidden(true) // Redundant with score above
        }
    }
    .padding()
    .background(Color(UIColor.systemGray6))
    .cornerRadius(12)
    .accessibilityElement(children: .combine)
    .accessibilityLabel(result.passed ? "Exam passed" : "Exam failed")
    
    // ✓ Category Breakdown (table-like structure)
    VStack(alignment: .leading, spacing: 1) {
        Text("Performance by Category")
            .font(.headline)
            .padding(.bottom, 8)
            .accessibilityAddTraits(.isHeader)
        
        ForEach(result.categoryBreakdown, id: \.category) { breakdown in
            CategoryResultRow(breakdown: breakdown)
        }
    }
    .accessibilityElement(children: .contain)
    
    Spacer()
    
    // ✓ Action buttons
    VStack(spacing: 12) {
        Button(action: reviewWeakAreas) {
            Label("Review Weak Areas", systemImage: "book.fill")
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.filled)
        .frame(minHeight: 48)
        
        Button(action: returnHome) {
            Text("Back to Home")
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.bordered)
        .frame(minHeight: 48)
    }
}

// ✓ Extracted component for reusability & accessibility testing
struct CategoryResultRow: View {
    let breakdown: CategoryBreakdown
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(breakdown.category.name)
                    .font(.body, weight: .semibold)
                
                Text("\(breakdown.correct)/\(breakdown.total) correct")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(Int(breakdown.percentage))%")
                .font(.headline, weight: .bold)
                .foregroundColor(breakdown.percentage >= 80 ? .green : .orange)
                .monospacedDigit()
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(8)
        .accessibilityLabel("\(breakdown.category.name)")
        .accessibilityValue("\(breakdown.correct) of \(breakdown.total) correct, \(Int(breakdown.percentage))%")
    }
}