// Services/ProgressTrackingService.swift (extension)
extension ProgressTrackingService {
    func questionsReviewDue() -> [Question] {
        let now = Date()
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        
        return allQuestions.filter { q in
            let lastReviewed = lastReviewDate(for: q.id) ?? .distantPast
            return lastReviewed < sevenDaysAgo
        }
    }
    
    func scheduleReview(for questionId: Int, interval: Int = 7) {
        let reviewDate = Calendar.current.date(byAdding: .day, value: interval, to: Date())!
        userDefaults.set(reviewDate, forKey: "review_\(questionId)")
    }
}

// Views/Screens/ReviewQueueScreen.swift
struct ReviewQueueScreen: View {
    @StateObject var viewModel: QuestionViewModel
    @ObservedObject var progress: ProgressTrackingService
    
    var body: some View {
        NavigationStack {
            let dueQuestions = progress.questionsReviewDue()
            
            if dueQuestions.isEmpty {
                Text("Keine Wiederholungen fällig!")
                    .foregroundColor(.secondary)
            } else {
                List(dueQuestions) { q in
                    NavigationLink(destination: QuestionScreen(question: q)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(q.text).font(.body)
                            Text("Kategorie: \(q.category)")
                                .font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Wiederholung fällig (\(dueQuestions.count))")
        }
    }
}