// File: PracticeView.swift
import SwiftUI

struct PracticeView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var selectedCategory: String?
    @State private var selectedDifficulty: Question.Difficulty?

    let categories = ["Geschwindigkeit", "Vorfahrt", "Schilder", "Technik", "Umwelt"]
    let difficulties = Question.Difficulty.allCases

    var body: some View {
        NavigationStack {
            List {
                Section("Kategorie") {
                    Picker("Kategorie", selection: $selectedCategory) {
                        Text("Alle").tag(nil as String?)
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category as String?)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Schwierigkeit") {
                    Picker("Schwierigkeit", selection: $selectedDifficulty) {
                        Text("Alle").tag(nil as Question.Difficulty?)
                        ForEach(difficulties, id: \.self) { difficulty in
                            Text(difficulty.rawValue.capitalized).tag(difficulty as Question.Difficulty?)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section {
                    NavigationLink {
                        QuestionListView(
                            questions: QuestionService.shared.getQuestions(
                                for: selectedCategory,
                                difficulty: selectedDifficulty
                            )
                        )
                    } label: {
                        HStack {
                            Text("Fragen starten")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                    .disabled(QuestionService.shared.getQuestions(for: selectedCategory, difficulty: selectedDifficulty).isEmpty)
                }
            }
            .navigationTitle("Üben")
        }
    }
}

struct QuestionListView: View {
    let questions: [Question]

    var body: some View {
        List(questions) { question in
            NavigationLink {
                QuestionDetailView(question: question)
            } label: {
                VStack(alignment: .leading) {
                    Text(question.text)
                        .font(.subheadline)
                    Text(question.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Fragen")
    }
}
