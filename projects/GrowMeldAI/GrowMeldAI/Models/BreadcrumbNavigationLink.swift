import SwiftUI

struct BreadcrumbNavigationLink: View {
    let title: String
    let destination: AnyView
    let isActive: Bool

    init(title: String, isActive: Bool = false, @ViewBuilder destination: () -> some View) {
        self.title = title
        self.isActive = isActive
        self.destination = AnyView(destination())
    }

    var body: some View {
        NavigationLink(destination: destination) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(isActive ? .primary : .accentColor)
                .fontWeight(isActive ? .semibold : .regular)
                .frame(minWidth: A11yConstants.minTouchTarget, minHeight: A11yConstants.minTouchTarget)
        }
        .disabled(isActive)
        .accessibilityLabel(isActive ? "\(title), current page" : title)
        .accessibilityHint(isActive ? "" : "Navigate to \(title)")
    }
}