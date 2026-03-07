func fetchTestFixData() {
      dataService.loadQuestions { fetchedQuestions in
          self.questions = fetchedQuestions
          self.isLoading = false
      }
  }

// ---

@Published var errorMessage: String?

// ---

private var contentView: some View {
      if viewModel.isLoading {
          ProgressView("Lade Fragen...")
              .padding()
      } else if let errorMessage = viewModel.errorMessage {
          Text(errorMessage)
              .foregroundColor(.red)
              .padding()
      } else {
          List(viewModel.questions) { question in
              QuestionRow(question: question)
          }
      }
  }

// ---

if question.isCorrect {
      Text("Deine Antwort: \(question.givenAnswer)").foregroundColor(Color("CorrectAnswerColor"))
  } else {
      Text("Deine Antwort: \(question.givenAnswer)").foregroundColor(Color("IncorrectAnswerColor"))
  }

// ---

if let errorMessage = viewModel.errorMessage {
    VStack {
        Text(errorMessage)
            .foregroundColor(.red)
            .padding()
        Button("Erneut versuchen") {
            viewModel.fetchTestFixData()
        }
        .padding()
    }
}

// ---

if let errorMessage = viewModel.errorMessage {
       VStack {
           Text(errorMessage)
               .foregroundColor(.red)
               .padding()
           Button("Erneut versuchen") {
               viewModel.fetchTestFixData()
           }
           .padding()
       }
   }

// ---

Button("Erneut versuchen") {
      viewModel.fetchTestFixData()
  }
  .padding()
  .disabled(viewModel.isLoading) // Disable during loading

// ---

Button(action: { viewModel.fetchTestFixData() }) {
        Text("Erneut versuchen")
    }
    .accessibilityLabel("Try again to fetch questions")

// ---

func testFetchQuestions_withNetworkError() {
      // Mocking network failure scenario
  }