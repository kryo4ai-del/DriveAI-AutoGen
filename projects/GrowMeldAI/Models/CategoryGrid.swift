struct CategoryGrid: View {
    let categories: [CategoryStats]
    
    let columns = [
        GridItem(.flexible(minimum: 160), spacing: 16),  // ✅ Minimum 160pt
        GridItem(.flexible(minimum: 160), spacing: 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(categories) { category in
                CategoryCard(category: category)
                    .frame(minHeight: 160)  // ✅ Enforce minimum height
            }
        }
        .padding()
    }
}
