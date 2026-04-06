import SwiftUI

struct DynamicTypePreview: View {
    var body: some View {
        Text("Dynamic Type Preview")
            .font(.body)
            .environment(\.sizeCategory, .accessibilityExtraLarge)
    }
}