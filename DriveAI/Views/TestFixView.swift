import SwiftUI

struct TestFixView: View {
    @StateObject private var viewModel = TestFixViewModel()
    
    var body: some View {
        NavigationView {
            contentView
                .navigationTitle("TestFix")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            loadingView
        } else if let errorMessage = viewModel.errorMessage {
            errorView(message: errorMessage)
        } else {
            questionsListView
        }
    }

    private var loadingView: some View {
        ProgressView("Lade Fragen...")
            .padding()
    }

    private func errorView(message: String) -> some View {
        VStack {
            Text(message)
                .foregroundColor(.red)
                .padding()
            Button("Erneut versuchen") {
                viewModel.fetchTestFixData()
            }
            .padding()
            .disabled(viewModel.isLoading)  // Disable while loading
            .accessibilityLabel("Try again to fetch questions")
        }
    }

    private var questionsListView: some View {
        List(viewModel.questions) { question in
            QuestionRow(question: question)
        }
        .listStyle(PlainListStyle())
    }
}