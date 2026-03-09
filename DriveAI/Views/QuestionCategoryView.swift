import SwiftUI

struct QuestionCategoryView: View {
    @StateObject private var viewModel = QuestionCategoryViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Lädt...") // "Loading..." in German
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if viewModel.categories.isEmpty {
                    Text("Keine Kategorien verfügbar.") // "No categories available." in German
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(viewModel.categories) { category in
                        NavigationLink(destination: QuestionsListView(category: category)) {
                            Text(category.name)
                                .font(.headline)
                        }
                    }
                    .navigationTitle("Kategorien") // "Categories" in German
                    .listStyle(PlainListStyle())
                }
            }
        }
    }
}