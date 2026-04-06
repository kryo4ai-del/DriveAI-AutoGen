import SwiftUI

// GOOD: Clear separation
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        Text("Dashboard")
    }
}

class DashboardViewModel: ObservableObject {
    @Published var score: Double = 0.0
    
    func calculateScore() -> Double {
        return score
    }
}

// Example of view using ViewModel
struct DashboardScoreView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        Text(String(format: "Score: %.1f%%", viewModel.calculateScore()))
    }
}