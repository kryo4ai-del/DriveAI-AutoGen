import SwiftUI

struct AnxietyPicker: View {

    @Binding var selected: AnxietyLevel
    var onChange: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AnxietyLevel.allCases) { level in
                AnxietySegment(
                    level: level,
                    isSelected: selected == level
                )
                .onTapGesture {
                    guard selected != level else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selected = level
                    }
                    onChange()
                }
            }
        }
        .padding(4)
        .background(Color(.systemFill), in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Segment

private struct AnxietySegment: View {

    let level: AnxietyLevel
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(level.emoji)
                .font(.system(size: 24))
            Text(level.label)
                .font(.caption2)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .primary : .secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: 10)
                    .fill(level.color.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(level.color.opacity(0.4), lineWidth: 1.5)
                    )
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}