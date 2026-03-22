import SwiftUI
private struct FilterButton: View {
    let label: String
    let isSelected: Bool
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .frame(minHeight: 44)  // Ensure minimum height
            .padding(.horizontal, 12)
            .padding(.vertical, 12)  // Increase vertical padding
            .background(isSelected ? color : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
        }
        .accessibilityLabel("Filter: \(label)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}