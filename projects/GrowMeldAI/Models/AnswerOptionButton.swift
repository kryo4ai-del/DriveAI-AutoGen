import SwiftUI

struct AnswerOptionButton: View {
    let option: AnswerOption
    let onSelectOption: (String) -> Void

    var body: some View {
        Button(action: { onSelectOption(option.id) }) {
            HStack(spacing: DesignTokens.Spacing.md) {
                Text(option.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            // ✅ Minimum 44x44pt touch target (Apple HIG)
            .frame(minHeight: A11yConstants.minTouchTarget)
            .padding(DesignTokens.Spacing.md)
            // ✅ Increase padding for stress/tremor tolerance
            .padding(.vertical, DesignTokens.Spacing.md + DesignTokens.Spacing.sm)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Answer option")
        .accessibilityValue(option.text)
        // ✅ Document touch target requirement
        .accessibilityHint("Double-tap to select. Minimum 44-point touch target.")
    }
}

// MARK: - Minimal AnswerOption model (if not defined elsewhere)
struct AnswerOption: Identifiable {
    let id: String
    let text: String
}

// MARK: - Touch Target Constants
enum TouchTarget {
    static let minimum: CGFloat = 44    // Apple HIG minimum
    static let recommended: CGFloat = 48 // Better for users with tremors
}

// MARK: - DesignTokens (minimal stub if not defined elsewhere)
enum DesignTokens {
    enum Spacing {
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 16
    }
}