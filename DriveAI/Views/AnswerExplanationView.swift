// Views/AnswerExplanationView.swift
   struct AnswerExplanationView: View {
       @ObservedObject var viewModel: AnswerExplanationViewModel

       var body: some View {
           VStack {
               Text(viewModel.isCorrect ? NSLocalizedString("Correct", comment: "Correct answer message") : NSLocalizedString("Incorrect", comment: "Incorrect answer message"))
                   .font(.largeTitle)
                   .foregroundColor(viewModel.isCorrect ? .green : .red)
                   .padding(.top)

               // Additional UI elements...
           }
           .navigationTitle(NSLocalizedString("Answer Explanation", comment: "Title for answer explanation view"))
           .navigationBarTitleDisplayMode(.inline)
           .padding()
       }
   }

   // Views/QuestionView.swift
   struct QuestionView: View {
       @StateObject var viewModel = AnswerExplanationViewModel()
       var question: Question

       @State private var isExplanationPresented = false
       @State private var selectedAnswerId: UUID?
       @State private var buttonState: ButtonState = .idle

       var body: some View {
           VStack {
               // Question and answer buttons...
           }
           .sheet(isPresented: $isExplanationPresented) {
               AnswerExplanationView(viewModel: viewModel)
           }
           .padding()
       }
   }