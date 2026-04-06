// ViewModels/Home/HomeViewModel.swift
@MainActor
class HomeViewModel: BaseViewModel {
    @Published var categoryProgress: [String: Double] = [:]
    
    // Add accessible text representation
    func accessibilityTextForCategory(_ category: String) -> String {
        let percentage = categoryProgress[category] ?? 0
        let percentageText = String(format: "%.0f%%", percentage * 100)
        return "\(category): \(percentageText) abgeschlossen"
    }
    
    var categoryProgressAccessibilityText: String {
        let items = categoryProgress.map { category, percentage in
            String(format: "%@: %.0f%% abgeschlossen", category, percentage * 100)
        }
        return items.joined(separator: "; ")
    }
}