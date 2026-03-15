struct ExamReadinessView: View {
    @StateObject var viewModel: ExamReadinessViewModel
    let getCategoryName: (String) -> String  // Injected lookup
    
    // In the loop:
    CategoryProgressRow(
        categoryName: getCategoryName(categoryId),
        score: score,
        isFocusArea: true
    )
}

// Usage (in Profile or Dashboard):
// [FK-019 sanitized] ExamReadinessView(
// [FK-019 sanitized]     viewModel: vm,
// [FK-019 sanitized]     getCategoryName: { id in
// [FK-019 sanitized]         allCategories.first(where: { $0.id == id })?.name ?? id
    }
// [FK-019 sanitized] )