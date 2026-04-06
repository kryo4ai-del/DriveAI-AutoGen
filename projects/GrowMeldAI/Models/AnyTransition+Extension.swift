// ✅ FIXED (respects accessibility motion settings)
@Environment(\.accessibilityReduceMotion) var reduceMotion

var body: some View {
    DisclosureGroup(isExpanded: $showMore) {
        Text(category.description)
            .transition(
                reduceMotion
                    ? .opacity  // ❌ No motion
                    : .opacity.combined(with: .scale)  // Subtle motion if allowed
            )
    } label: {
        Text("More")
    }
}

// Or use a helper modifier
extension AnyTransition {
    static var accessibilityFriendly: AnyTransition {
        @Environment(\.accessibilityReduceMotion) var reduceMotion
        return reduceMotion ? .opacity : .opacity.combined(with: .scale)
    }
}

// Usage
.transition(.accessibilityFriendly)