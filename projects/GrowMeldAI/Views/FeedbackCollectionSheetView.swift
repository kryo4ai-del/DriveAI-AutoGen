import SwiftUI

// MARK: - FeedbackService Environment Key

struct FeedbackServiceKey: EnvironmentKey {
    static let defaultValue: FeedbackServiceProtocol = DefaultFeedbackService(
        persistenceService: UserDefaultsFeedbackPersistence()
    )
}

extension EnvironmentValues {
    var feedbackService: FeedbackServiceProtocol {
        get { self[FeedbackServiceKey.self] }
        set { self[FeedbackServiceKey.self] = newValue }
    }
}

// MARK: - FeedbackService Protocol

protocol FeedbackServiceProtocol {
    func submitFeedback(_ feedback: FeedbackEntry) async throws
    func fetchFeedback() async throws -> [FeedbackEntry]
}

// MARK: - FeedbackPersistence Protocol

protocol FeedbackPersistenceProtocol {
    func save(_ feedback: FeedbackEntry) throws
    func loadAll() throws -> [FeedbackEntry]
}

// MARK: - FeedbackEntry Model

struct FeedbackEntry: Identifiable, Codable {
    let id: UUID
    var rating: Int
    var comment: String
    var timestamp: Date

    init(id: UUID = UUID(), rating: Int, comment: String, timestamp: Date = Date()) {
        self.id = id
        self.rating = rating
        self.comment = comment
        self.timestamp = timestamp
    }
}

// MARK: - UserDefaults-based Persistence (replaces SQLite)

final class UserDefaultsFeedbackPersistence: FeedbackPersistenceProtocol {
    private let storageKey = "com.growmeldai.feedback.entries"

    func save(_ feedback: FeedbackEntry) throws {
        var entries = (try? loadAll()) ?? []
        entries.append(feedback)
        let data = try JSONEncoder().encode(entries)
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    func loadAll() throws -> [FeedbackEntry] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }
        return try JSONDecoder().decode([FeedbackEntry].self, from: data)
    }
}

// MARK: - DefaultFeedbackService

final class DefaultFeedbackService: FeedbackServiceProtocol {
    private let persistenceService: FeedbackPersistenceProtocol

    init(persistenceService: FeedbackPersistenceProtocol) {
        self.persistenceService = persistenceService
    }

    func submitFeedback(_ feedback: FeedbackEntry) async throws {
        try persistenceService.save(feedback)
    }

    func fetchFeedback() async throws -> [FeedbackEntry] {
        try persistenceService.loadAll()
    }
}

// MARK: - FeedbackCollectionSheetView

struct FeedbackCollectionSheetView: View {
    @Environment(\.feedbackService) var feedbackService
    @Environment(\.dismiss) private var dismiss

    @State private var rating: Int = 3
    @State private var comment: String = ""
    @State private var isSubmitting: Bool = false
    @State private var submissionError: Error? = nil
    @State private var showSuccessBanner: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("How would you rate your experience?")) {
                    HStack(spacing: 12) {
                        ForEach(1...5, id: \.self) { star in
                            Button(action: { rating = star }) {
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .foregroundColor(star <= rating ? .yellow : .gray)
                                    .font(.title2)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(Text("\(star) star\(star == 1 ? "" : "s")"))
                            .accessibilityAddTraits(star <= rating ? .isSelected : [])
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section(header: Text("Comments (optional)")) {
                    TextEditor(text: $comment)
                        .frame(minHeight: 100)
                        .accessibilityLabel(Text("Feedback comments"))
                        .accessibilityHint(Text("Enter any additional comments about your experience"))
                }

                if let error = submissionError {
                    Section {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .accessibilityHidden(true)
                            Text(error.localizedDescription)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }

                if showSuccessBanner {
                    Section {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .accessibilityHidden(true)
                            Text("Thank you for your feedback!")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                    }
                }

                Section {
                    Button(action: submitFeedback) {
                        HStack {
                            Spacer()
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .padding(.trailing, 8)
                                Text("Submitting...")
                            } else {
                                Text("Submit Feedback")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(isSubmitting)
                    .accessibilityLabel(Text("Submit Feedback"))
                    .accessibilityHint(Text("Submits your rating and comments"))
                }
            }
            .navigationTitle("Share Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityLabel(Text("Cancel"))
                    .accessibilityHint(Text("Dismisses the feedback form without submitting"))
                }
            }
        }
    }

    // MARK: - Actions

    private func submitFeedback() {
        isSubmitting = true
        submissionError = nil
        showSuccessBanner = false

        let entry = FeedbackEntry(rating: rating, comment: comment)

        Task {
            do {
                try await feedbackService.submitFeedback(entry)
                await MainActor.run {
                    isSubmitting = false
                    showSuccessBanner = true
                    comment = ""
                    rating = 3
                }
                // Auto-dismiss after short delay
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    submissionError = error
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    FeedbackCollectionSheetView()
        .environment(\.feedbackService, DefaultFeedbackService(
            persistenceService: UserDefaultsFeedbackPersistence()
        ))
}