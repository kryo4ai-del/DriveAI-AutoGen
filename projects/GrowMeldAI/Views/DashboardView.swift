import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        Text("Dashboard")
    }
}

struct DashboardView2: View {
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        Text(String(format: "Score: %.1f%%", viewModel.calculateScore()))
    }
}

class DashboardViewModel: ObservableObject {
    @Published var score: Double = 0.0

    func calculateScore() -> Double {
        return score
    }
}