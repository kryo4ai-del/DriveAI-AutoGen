extension CategoryProgress {
    func withUpdatedProgress(totalAnswered: Int, correctCount: Int) -> Self {
        CategoryProgress(
            id: id,
            categoryName: categoryName,
            totalQuestionsAnswered: totalAnswered,
            correctCount: correctCount,
            lastUpdated: Date()
        )
    }
}