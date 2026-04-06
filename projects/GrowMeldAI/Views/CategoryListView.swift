struct CategoryListView: View {
    var body: some View {
        List {
            ForEach(categories) { category in
                CategoryRow(category: category)
                    .accessibilityElement(children: .combine)
                    // VoiceOver reads: category name → progress percentage → question count
            }
        }
    }
}