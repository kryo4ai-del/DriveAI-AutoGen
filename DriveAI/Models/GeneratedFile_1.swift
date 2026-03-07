guard viewModel.currentQuestionIndex < viewModel.questions.count else { return }
let question = viewModel.questions[viewModel.currentQuestionIndex]