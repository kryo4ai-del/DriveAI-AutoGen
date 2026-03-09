func loadCategories(completion: @escaping (Result<[QuestionCategory], Error>) -> Void) {
      // Load logic with completion handling.
  }

// ---

NavigationView {
    List(viewModel.categories) { category in
        NavigationLink(destination: QuestionsListView(category: category)) {
            HStack {
                Text(category.name)
                    .font(.headline)
                Spacer()
            }
        }
    }
    .navigationTitle("Kategorien")
    .listStyle(PlainListStyle())
}

// ---

func loadCategories(completion: @escaping (Result<[QuestionCategory], Error>) -> Void) {
    DispatchQueue.global().async {
        guard let url = Bundle.main.url(forResource: "Categories", withExtension: "json") else {
            completion(.failure(NSError(domain: "LocalDataServiceError", code: 404, userInfo: [NSLocalizedDescriptionKey: "File not found"])))
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let categories = try JSONDecoder().decode([QuestionCategory].self, from: data)
            completion(.success(categories))
        } catch {
            completion(.failure(error))
        }
    }
}

// ---

if viewModel.isLoading {
    ProgressView("Loading...")
} else {
    List(viewModel.categories) { category in
        NavigationLink(destination: QuestionsListView(category: category)) {
            Text(category.name).font(.headline)
        }
    }
}

// ---

if viewModel.categories.isEmpty && !viewModel.isLoading {
    Text("Keine Kategorien verfügbar.") // "No categories available." in German
        .font(.body)
        .foregroundColor(.gray)
}

// ---

ForEach(category.questions) { question in
    VStack(alignment: .leading) {
        Text(question.text)
            .font(.headline)
        ForEach(question.options, id: \.self) { option in
            Button(action: {
                // Handle answer selection
            }) {
                Text(option)
            }
            .padding(.vertical, 4)
        }
    }
    .padding(.bottom, 10)
}