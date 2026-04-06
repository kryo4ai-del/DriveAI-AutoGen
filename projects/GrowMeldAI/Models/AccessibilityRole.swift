import SwiftUI
import Accessibility

enum AccessibilityRole {
    case heading(level: Int)
    case button(label: String, hint: String?)
    case image(description: String)
    case element(traits: AccessibilityTraits)
}

struct AccessibilityService {
    static func configure(view: some View, role: AccessibilityRole) -> some View {
        switch role {
        case .heading(let level):
            return AnyView(view.accessibilityHeading(level))
        case .button(let label, let hint):
            return AnyView(view.accessibilityButton(label, hint: hint))
        case .image(let description):
            return AnyView(view.accessibilityImage(description: description))
        case .element(let traits):
            return AnyView(view.accessibilityElement(traits: traits))
        }
    }
}

// MARK: - View Extensions (Clean API Surface)
extension View {
    func accessibilityButton(_ label: String, hint: String? = nil) -> some View {
        self.modifier(AccessibilityButtonModifier(label: label, hint: hint))
    }

    func accessibilityHeading(_ level: Int = 1) -> some View {
        self.modifier(AccessibilityHeadingModifier(level: level))
    }
}

// MARK: - Private Modifiers (Implementation Details)
private struct AccessibilityButtonModifier: ViewModifier {
    let label: String
    let hint: String?

    func body(content: Content) -> some View {
        content
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
            .accessibilityRemoveTraits(.isImage)
    }
}

private struct AccessibilityHeadingModifier: ViewModifier {
    let level: Int

    func body(content: Content) -> some View {
        content
            .accessibilityHeading(AccessibilityHeading(level))
    }
}