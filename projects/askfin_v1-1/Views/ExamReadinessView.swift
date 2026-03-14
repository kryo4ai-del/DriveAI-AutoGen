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
ExamReadinessView(
    viewModel: vm,
    getCategoryName: { id in
        allCategories.first(where: { $0.id == id })?.name ?? id
    }
)