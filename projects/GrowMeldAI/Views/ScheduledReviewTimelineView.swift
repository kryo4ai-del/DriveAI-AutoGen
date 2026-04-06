import SwiftUI

struct ScheduledReviewTimelineView: View {
    let reviews: [ScheduledReview]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("scheduled_title", comment: ""))
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            
            Text(NSLocalizedString("scheduled_hint", comment: ""))
                .font(.footnote)
                .foregroundColor(.secondary)
                .accessibilityLabel("Spaced Repetition — optimal für langfristiges Gedächtnis")
            
            VStack(spacing: 8) {
                ForEach(reviews, id: \.id) { review in
                    HStack(spacing: 12) {
                        // Day badge (visual + accessible)
                        VStack(alignment: .center, spacing: 2) {
                            Text(NSLocalizedString("day_label", comment: ""))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text("\(review.day)")
                                .font(.headline)
                        }
                        .frame(width: 40)
                        .padding(8)
                        .background(Color(.systemGray5))
                        .cornerRadius(6)
                        .accessibilityHidden(true) // Redundant with text below
                        
                        // Description + count
                        VStack(alignment: .leading, spacing: 2) {
                            Text(review.description)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Label {
                                Text(NSLocalizedString(
                                    "practice_count_\(review.practiceCount)",
                                    comment: "Number of practice questions"
                                ))
                            } icon: {
                                Image(systemName: "book.fill")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Due date
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(NSLocalizedString("due", comment: ""))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text(review.dueDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(6)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(review.accessibilityLabel)
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

#Preview {
    ScheduledReviewTimelineView(
        reviews: [
            ScheduledReview(
                id: UUID(), day: 1,
                description: "1. Wiederholung – erste Verfestigung",
                practiceCount: 1,
                dueDate: .now
            ),
            ScheduledReview(
                id: UUID(), day: 3,
                description: "2. Wiederholung – Konsolidierung",
                practiceCount: 2,
                dueDate: .now.addingTimeInterval(3 * 86400)
            ),
            ScheduledReview(
                id: UUID(), day: 7,
                description: "3. Wiederholung – Langzeitgedächtnis",
                practiceCount: 2,
                dueDate: .now.addingTimeInterval(7 * 86400)
            )
        ]
    )
    .padding()
}