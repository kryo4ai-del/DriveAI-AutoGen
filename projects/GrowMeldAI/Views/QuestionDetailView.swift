// Views/Questions/QuestionDetailView.swift
import SwiftUI

struct QuestionDetailView: View {
    @StateObject private var viewModel: QuestionDetailViewModel
    @Environment(\.dismiss) var dismiss
    
    private let dataService: LocalDataService
    private let progressService: ProgressService
    let categoryId: String
    
    init(
        categoryId: String,
        dataService: LocalDataService,
        progressService: ProgressService
    ) {
        self.categoryId = categoryId
        self.dataService = dataService
        self.progressService = progressService
        _viewModel = StateObject(
            wrappedValue: QuestionDetailViewModel(
                categoryId: categoryId,
                dataService: dataService,
                progressService: progressService
            )
        )
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header with progress
                QuestionProgressBar(
                    current: viewModel.questionIndex + 1,
                    total: viewModel.totalQuestions
                )
                .padding(.bottom, 16)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Question text
                        if let question = viewModel.currentQuestion {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(question.text)
                                    .font(.system(.title3, design: .default))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .lineLimit(nil)
                                
                                if let imageUrl = question.imageUrl, !imageUrl.isEmpty {
                                    AsyncImage(url: URL(string: imageUrl)) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .cornerRadius(8)
                                    } placeholder: {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 200)
                                    }
                                }
                            }
                            .padding(.bottom, 24)
                            
                            // Answer options
                            VStack(spacing: 12) {
                                ForEach(question.options, id: \.self) { option in
                                    AnswerOptionView(
                                        text: option,
                                        isSelected: viewModel.selectedAnswer == option,
                                        isAnswered: viewModel.isAnswered,
                                        isCorrect: option == question.correctAnswer,
                                        userSelected: viewModel.selectedAnswer == option && viewModel.isAnswered
                                    )
                                    .onTapGesture {
                                        if !viewModel.isAnswered {
                                            viewModel.submitAnswer(option)
                                        }
                                    }
                                    .disabled(viewModel.isAnswered)
                                }
                            }
                            
                            // Feedback
                            if viewModel.isAnswered {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 8) {
                                        Image(systemName: viewModel.isCorrect == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .foregroundColor(viewModel.isCorrect == true ? .green : .red)
                                        
                                        Text(viewModel.feedbackMessage)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                    
                                    if let explanation = question.explanation, !explanation.isEmpty {
                                        Text("Erklärung: \(explanation)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(12)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                }
                                .padding(12)
                                .background(Color(viewModel.isCorrect == true ? UIColor.systemGreen : UIColor.systemRed).opacity(0.1))
                                .cornerRadius(8)
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                }
                
                // Navigation buttons
                HStack(spacing: 12) {
                    Button(action: { viewModel.previousQuestion() }) {
                        Label("Zurück", systemImage: "chevron.left")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.questionIndex == 0)
                    
                    if viewModel.isAnswered {
                        Button(action: { viewModel.nextQuestion() }) {
                            Label("Weiter", systemImage: "chevron.right")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.questionIndex >= viewModel.totalQuestions - 1)
                    }
                }
                .padding(16)
            }
            
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
        .navigationTitle("Fragen")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Fehler", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { dismiss() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

// MARK: - Supporting Views

struct QuestionProgressBar: View {
    let current: Int
    let total: Int
    
    var body: some View {
        VStack(spacing: 8) {
            ProgressView(value: Double(current), total: Double(total))
                .tint(.blue)
            
            HStack {
                Text("Frage \(current) von \(total)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(Double(current) / Double(total) * 100))%")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
    }
}

#Preview {
    NavigationStack {
        QuestionDetailView(
            categoryId: "traffic-signs",
            dataService: MockDataService(),
            progressService: MockProgressService()
        )
    }
}