// This requires the NavigationStack path to be accessible.
// Interim fix for MVP — pop twice using a helper:
struct DismissTwiceModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EmptyView()
            }
        }
    }
}