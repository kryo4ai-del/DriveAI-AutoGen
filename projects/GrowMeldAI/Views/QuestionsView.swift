// File: QuestionsView.swift
import SwiftUI

struct QuestionsView: View {
    let category: TheoryCategory
    @State private var currentIndex = 0
    @State private var selectedAnswer: String?
    @State private var showResult = false

    let questions: [Question] = [
        Question(
            text: "What does this sign mean?",
            options: ["Stop", "Yield", "Go"],
            correctAnswer: "Stop",
            difficulty: 1
        ),
        Question(
            text: "When should you use your headlights?",
            options: ["At night", "In fog", "Both"],
            correctAnswer: "Both",
            difficulty: 2
        )
    ]

    var body: some View {
        VStack {
            if currentIndex < questions.count {
                QuestionView(
                    question: questions[currentIndex],
                    selectedAnswer: $selectedAnswer,
                    showResult: $showResult
                )

                if showResult {
                    Button("Next") {
                        currentIndex += 1
                        selectedAnswer = nil
                        showResult = false
                    }
                }
            } else {
                Text("Quiz Complete!")
            }
        }
        .padding()
        .navigationTitle(category.name)
    }
}