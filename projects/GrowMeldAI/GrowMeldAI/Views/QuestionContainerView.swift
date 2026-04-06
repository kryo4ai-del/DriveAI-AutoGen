// Option A: Pass ViewModel via @StateObject in parent
struct QuestionContainerView: View {
    @StateObject private var viewModel = KIIdentifikationViewModel()
    let question: Question
    
    var body: some View {
        KIIdentificationQuestionView(
            question: question,
            viewModel: viewModel,  // Pass directly
            onComplete: { result in }
        )
    }
}

// Option B: Remove StateObject, use Environment