// Views/QuestionView.swift
import SwiftUI

enum ButtonState {
    case idle, loading, ready
}

struct QuestionView: View {
    @StateObject var viewModel = AnswerExplanationViewModel()
    var question: Question

    @State private var isExplanationPresented = false
    @State private var selectedAnswerId: UUID?
    @State private var buttonState: ButtonState = .idle

    var body: some View {
        VStack {
            Text(question.text)
                .font(.title)
                .padding()
                .multilineTextAlignment(.leading)

            ForEach(question.options) { option in
                Button(action: {
                    buttonState = .loading
                    selectedAnswerId = option.id
                    viewModel.loadQuestion(question, selectedAnswerId: option.id)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Simulate loading delay
                        isExplanationPresented = true
                        buttonState = .ready
                    }
                }) {
                    Text(option.text)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                        .padding(5)
                }
                .disabled(buttonState == .loading) // Disable while loading
            }
        }
        .sheet(isPresented: $isExplanationPresented) {
            AnswerExplanationView(viewModel: viewModel)
        }
        .padding()
    }
}