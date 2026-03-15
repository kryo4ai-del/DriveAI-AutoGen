import SwiftUI
struct CategoryReadinessRow: View {
    let category: CategoryReadiness
    
    var body: some View {
        HStack(spacing: 12) {
            // ✅ Icon with accessibility label
            Image(systemName: category.priorityLevel.icon)
                .foregroundColor(category.priorityLevel.color)
                .accessibilityLabel(Text(category.priorityLevel.description))
                .accessibilityAddTraits(.isImage)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(.body)
                    .fontWeight(.medium)
                
                HStack(spacing: 8) {
                    Text("\(Int(category.readinessPercentage))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(category.priorityLevel.color)
                    
                    Text(category.priorityLevel.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // ✅ Add progress indicator
            ProgressView(value: category.readinessPercentage / 100.0)
                .tint(category.priorityLevel.color)
                .frame(width: 40)
                .accessibilityHidden(true) // Redundant with text above
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        // ✅ Semantic grouping for entire row
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            Text(String(
                localized: "\(category.name), \(Int(category.readinessPercentage)) percent ready",
                comment: "Category readiness row"
            ))
        )
        .accessibilityValue(
            Text(category.priorityLevel.description)
        )
        .accessibilityHint(Text(String(
            localized: "Double tap to study \(category.name)",
            comment: "Category row hint"
        )))
    }
}