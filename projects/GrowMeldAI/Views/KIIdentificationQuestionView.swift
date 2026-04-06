// Views/KIIdentification/KIIdentificationQuestionView.swift

import SwiftUI

struct KIIdentificationQuestionView: View {
    @StateObject private var viewModel: KIIdentifikationViewModel
    let question: Question
    let onComplete: (IdentificationResult) -> Void
    
    @State private var selectedAnswer: String?
    
    init(
        question: Question,
        onComplete: @escaping (IdentificationResult) -> Void,
        viewModel: KIIdentifikationViewModel = KIIdentifikationViewModel()
    ) {
        self.question = question
        self.onComplete = onComplete
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            switch viewModel.identificationState {
            case .waiting:
                questionContent
                    .transition(.opacity)
                
            case .processing:
                processingView
                    .transition(.opacity)
                
            case .completed(let result):
                KIIdentificationSuccessView(
                    result: result,
                    question: question,
                    onNext: { onComplete(result) }
                )
                .transition(.scale.combined(with: .opacity))
                
            case .failed(let error):
                errorView(error)
                    .transition(.opacity)
            }
        }
        .onAppear {
            viewModel.startIdentificationTimer(for: question)
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.identificationState)
    }
    
    private var questionContent: some View {
        VStack(spacing: 20) {
            // Question text
            VStack(alignment: .leading, spacing: 12) {
                Text(question.text)
                    .font(.body)
                    .lineLimit(nil)
                    .foregroundColor(.primary)
                
                if let imageURL = question.imageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(8)
                        case .loading:
                            ProgressView()
                                .frame(height: 200)
                        case .empty:
                            EmptyView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
            .padding(20)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            // Answer options
            VStack(spacing: 12) {
                ForEach(question.answers, id: \.id) { answer in
                    answerButton(answer)
                }
            }
            
            Spacer()
        }
        .padding(20)
    }
    
    private func answerButton(_ answer: Answer) -> some View {
        Button(action: {
            selectedAnswer = answer.id
            viewModel.submitAnswer(answer.id)
        }) {
            HStack(spacing: 12) {
                Circle()
                    .strokeBorder(Color.blue, lineWidth: 2)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 12, height: 12)
                            .opacity(selectedAnswer == answer.id ? 1 : 0)
                    )
                
                Text(answer.text)
                    .font(.body)
                    .lineLimit(nil)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(14)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .contentShape(Rectangle())
        }
        .disabled(viewModel.identificationState != .waiting)
        .opacity(viewModel.identificationState == .waiting ? 1 : 0.6)
    }
    
    private var processingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2, anchor: .center)
            Text("Überprüfung läuft...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            Text("Fehler")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: {
                viewModel.reset()
            }) {
                Text("Erneut versuchen")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(20)
    }
}

#Preview {
    KIIdentificationQuestionView(
        question: Question.preview,
        onComplete: { _ in }
    )
}