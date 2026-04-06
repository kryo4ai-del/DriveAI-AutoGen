// ❌ BAD: Component has state
struct QuestionOption: View {
    @State var isSelected = false  // WRONG
    var body: some View { /* ... */ }
}

// ✅ GOOD: Component receives binding
struct QuestionOption: View {
    @Binding var isSelected: Bool  // State lives in ViewModel
    var body: some View { /* ... */ }
}