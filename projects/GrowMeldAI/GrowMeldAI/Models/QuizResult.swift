struct QuizResult: Codable {
    let region: Region
    let score: Int
    let maxScore: Int
    let category: String?
    let date: Date
    let duration: Int  // seconds
}

@MainActor
final class ProgressService: ObservableObject {
    @Published var quizResults: [QuizResult] = []
    
    private let defaults = UserDefaults.standard
    private let resultsKey = "app.quizResults"
    
    func recordResult(_ result: QuizResult) {
        quizResults.append(result)
        persistResults()
    }
    
    func getLatestScore(for region: Region) -> Int? {
        quizResults.filter { $0.region == region }.last?.score
    }
    
    func getStreakDays(for region: Region) -> Int {
        let calendar = Calendar.current
        let results = quizResults.filter { $0.region == region }.sorted { $0.date < $1.date }
        
        var streak = 0
        var lastDate: Date?
        
        for result in results.reversed() {
            if let last = lastDate {
                let days = calendar.dateComponents([.day], from: result.date, to: last)
                if days.day == 1 {
                    streak += 1
                } else {
                    break
                }
            } else {
                streak = 1
            }
            lastDate = result.date
        }
        
        return streak
    }
}