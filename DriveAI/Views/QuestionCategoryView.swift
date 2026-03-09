import SwiftUI

struct QuestionCategoryView: View {
    @StateObject var viewModel = QuestionCategoryViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.categories) { category in
                NavigationLink(destination: QuestionsForCategoryView(category: category)) {
                    VStack(alignment: .leading) {
                        Text(category.name)
                            .font(.headline)
                            .accessibilityLabel(Text("Kategorie: \(category.name)")) // Accessibility Improvement
                        Text("\(category.questionCount) Fragen")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle(LocalizedStrings.categoriesTitle) // Using localization
        }
    }
}