// Features/Feedback/Views/FlaggedQuestionsListView.swift
struct FlaggedQuestionsListView: View {
    @StateObject private var viewModel: FlaggedQuestionsViewModel
    @Environment(\.dismiss) var dismiss
    
    enum SortOption: String, CaseIterable {
        case dateAdded = "Zuletzt flagged"
        case category = "Nach Kategorie"
        case readyFirst = "Zum Wiederholen bereit"
        
        var id: String { self.rawValue }
    }
    
    @State private var sortOption: SortOption = .readyFirst
    
    init(feedbackService: FeedbackService, questionsService: QuestionsService) {
        _viewModel = StateObject(
            wrappedValue: FlaggedQuestionsViewModel(
                feedbackService: feedbackService,
                questionsService: questionsService
            )
        )
    }
    
    var sortedQuestions: [Question] {
        switch sortOption {
        case .dateAdded:
            return viewModel.flaggedQuestions.sorted {
                ($0.userFeedback?.timestamp ?? .distantPast) >
                ($1.userFeedback?.timestamp ?? .distantPast)
            }
        case .category:
            return viewModel.flaggedQuestions.sorted { $0.category < $1.category }
        case .readyFirst:
            return viewModel.flaggedQuestions.sorted {
                ($0.isReadyForReview, $0.userFeedback?.timestamp ?? .distantPast) >
                ($1.isReadyForReview, $1.userFeedback?.timestamp ?? .distantPast)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Flagged Fragen")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text("\(viewModel.flaggedQuestions.count) Fragen · \(viewModel.readyForReviewCount) bereit")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                
                // Sort picker
                Picker("Sortieren", selection: $sortOption) {
                    ForEach(SortOption.allCases, id: \.id) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // List
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if viewModel.flaggedQuestions.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.green)
                        Text("Keine flagged Fragen")
                            .font(.headline)
                        Text("Alle deine unsicheren Fragen sind gelöst!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    List {
                        ForEach(sortedQuestions) { question in
                            NavigationLink(destination: {
                                FlaggedQuestionDetailView(question: question, viewModel: viewModel)
                            }) {
                                FlaggedQuestionListItemView(question: question)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Zurück") { dismiss() }
                }
            }
        }
        .task {
            await viewModel.loadFlaggedQuestions()
        }
    }
}

// List item component
struct FlaggedQuestionListItemView: View {
    let question: Question
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(question.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Text(question.text)
                        .font(.body)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                if question.isReadyForReview {
                    Badge(count: 1) // Visual indicator
                }
            }
            
            if let feedback = question.userFeedback {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text(feedback.category.label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// Detail view with previous feedback
struct FlaggedQuestionDetailView: View {
    let question: Question
    let viewModel: FlaggedQuestionsViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            // Previous feedback reminder
            if let feedback = question.userFeedback {
                PreviousFeedbackReminderView(feedback: feedback)
            }
            
            // Official explanation
            VStack(alignment: .leading, spacing: 8) {
                Text("Erklärung")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(question.explanation)
                    .font(.body)
                    .lineHeight(1.6)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            Spacer()
            
            // Mark as reviewed
            Button(action: {
                Task {
                    await viewModel.markAsReviewed(question)
                    dismiss()
                }
            }) {
                Text("Verstanden — Weiter")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .navigationTitle("Flagged Frage")
        .navigationBarTitleDisplayMode(.inline)
    }
}