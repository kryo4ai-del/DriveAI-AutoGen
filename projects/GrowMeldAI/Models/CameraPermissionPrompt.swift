// BUGGY CODE
struct CameraPermissionPrompt: View {
    @StateObject private var viewModel = CameraPermissionViewModel()
    
    var body: some View {
        ZStack {
            // ... always renders prompt, never renders error cards
            VStack(spacing: 24) {
                // Prompt UI
            }
        }
        .alert(...) // Alert shown, but underlying view still shows original prompt
    }
}