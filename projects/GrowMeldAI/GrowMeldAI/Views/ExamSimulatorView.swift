// File: ExamSimulatorView.swift
import SwiftUI

struct ExamSimulatorView: View {
    @EnvironmentObject var examEngine: ExamEngine
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        NavigationStack {
            if let question = examEngine.currentQuestion {
                QuestionView(question: question)
            } else {
                ExamStartView()
            }
        }
    }
}

struct ExamStartView: View {
    @EnvironmentObject var examEngine: ExamEngine

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "graduationcap")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Prüfungssimulation")
                .font(.title)
                .fontWeight(.bold)

            Text("Eine Prüfung besteht aus 30 Fragen und dauert 30 Minuten.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button {
                let questions = QuestionService.shared.getQuestions()
                examEngine.startExam(with: questions)
            } label: {
                Text("Prüfung starten")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Prüfung")
    }
}
