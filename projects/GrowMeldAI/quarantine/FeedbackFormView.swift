// Views/FeedbackFormView.swift
struct FeedbackFormView: View {
    @StateObject private var viewModel: FeedbackFormViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: FormField?
    
    enum FormField {
        case feedbackText, email
    }
    
    init(feedbackService: FeedbackService = LocalFeedbackService()) {
        _viewModel = StateObject(
            wrappedValue: FeedbackFormViewModel(feedbackService: feedbackService)
        )
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Feedback"), footer: characterCounter) {
                    TextEditor(text: $viewModel.feedbackText)
                        .lineLimit(5...)
                        .focused($focusedField, equals: .feedbackText)
                        .accessibilityLabel(String(localized: "feedback.textarea.label"))
                        .accessibilityHint(String(localized: "feedback.textarea.hint"))
                }
                
                Section(header: Text(String(localized: "feedback.category.label"))) {
                    Picker(String(localized: "feedback.category.label"),
                           selection: $viewModel.selectedCategory) {
                        ForEach(FeedbackCategory.allCases, id: \.self) { category in
                            Text(category.localizedName).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text(String(localized: "feedback.email.label"))) {
                    TextField(
                        String(localized: "feedback.email.placeholder"),
                        text: $viewModel.contactEmail
                    )
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .focused($focusedField, equals: .email)
                    .accessibilityLabel(String(localized: "feedback.email.label"))
                }
                
                if let error = viewModel.submitError {
                    Section {
                        Label(error.userMessage, systemImage: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: submitForm) {
                        if viewModel.isSubmitting {
                            HStack {
                                ProgressView()
                                    .tint(.white)
                                Text(String(localized: "feedback.submitting"))
                            }
                        } else {
                            Text(String(localized: "feedback.submit"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
                }
            }
            .navigationTitle(String(localized: "feedback.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    @ViewBuilder
    private var characterCounter: some View {
        HStack {
            Spacer()
            Text("\(viewModel.feedbackText.count)/500")
                .font(.caption)
                .foregroundColor(
                    viewModel.feedbackText.count > 500 ? .red : .secondary
                )
                .accessibilityLabel("Character count: \(viewModel.feedbackText.count) of 500")
        }
    }
    
    private func submitForm() {
        Task {
            await viewModel.submitFeedback()
            if viewModel.submitError == nil {
                dismiss()
            }
        }
    }
}

#Preview {
    FeedbackFormView()
}