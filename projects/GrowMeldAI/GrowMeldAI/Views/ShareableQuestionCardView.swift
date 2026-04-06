struct ShareableQuestionCardView: View {
    let question: Question
    @StateObject private var viewModel: ShareQuestionViewModel
    @State private var errorAlert: AlertState?
    @State private var isGeneratingImage = false
    
    var body: some View {
        VStack(spacing: 16) {
            // ... card content ...
            
            Button(action: { handleShare() }) {
                if isGeneratingImage {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Generating...")
                    }
                } else {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
            .disabled(isGeneratingImage)
            
            if let error = errorAlert {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                    Text(error.message)
                        .font(.caption)
                        .foregroundColor(.red)
                    Spacer()
                    Button("Dismiss") {
                        errorAlert = nil
                    }
                    .font(.caption)
                }
                .padding(12)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .sheet(isPresented: $viewModel.isShareSheetPresented) {
            ShareSheet(items: viewModel.shareItems)
        }
        .alert("Error", isPresented: .constant(errorAlert != nil), presenting: errorAlert) { _ in
            Button("OK") { errorAlert = nil }
        } message: { error in
            Text(error.message)
        }
    }
    
    private func handleShare() {
        Task {
            isGeneratingImage = true
            defer { isGeneratingImage = false }
            
            do {
                try await viewModel.prepareShare(for: question)
            } catch {
                errorAlert = AlertState(
                    message: error.localizedDescription,
                    id: UUID()
                )
            }
        }
    }
}

struct AlertState: Identifiable {
    let id: UUID
    let message: String
}