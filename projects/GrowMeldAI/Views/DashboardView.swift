// ✅ GOOD: Clear separation
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        // View logic only
    }
}

// ❌ BAD: Business logic in View
struct DashboardView: View {
    var body: some View {
        Text(String(format: "Score: %.1f%%", calculateScore()))
        // ^ Avoid — move to ViewModel
    }
    
    private func calculateScore() -> Double { ... }
}