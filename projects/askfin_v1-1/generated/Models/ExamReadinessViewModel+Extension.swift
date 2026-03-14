// ... (after dismissError)

/// Navigate to category drill-down
func drillDownToCategory(_ category: WeakCategory) {
    selectedWeakCategoryID = category.categoryID
}

/// Reset state (used on view dismiss)
func reset() {
    readinessResult = nil
    error = nil
    selectedWeakCategoryID = nil
}

// MARK: - Preview

#if DEBUG
extension ExamReadinessViewModel {
    static let preview = {
        let vm = ExamReadinessViewModel(
            analysisService: ReadinessAnalysisService(
                dataService: LocalDataService.preview
            ),
            dataService: LocalDataService.preview
        )
        vm.readinessResult = .preview
        return vm
    }()
}
