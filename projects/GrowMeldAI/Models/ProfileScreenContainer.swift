// ✅ GOOD: Clean separation
struct ProfileScreenContainer: View {
    @StateObject private var viewModel = ProfileViewModel()
    var body: some View {
        ProfileScreenContent(viewModel: viewModel)
    }
}

struct ProfileScreenContent: View {
    @ObservedObject var viewModel: ProfileViewModel
    // ... UI code
}