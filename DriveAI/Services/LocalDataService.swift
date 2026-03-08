class LocalDataService {
    static let shared = LocalDataService()
    
    private init() {}
    
    func fetchQuestions(completion: @escaping ([Question]) -> Void) {
        // Simulate asynchronous data fetching
        DispatchQueue.global().async {
            // Fetch from local JSON or SQLite (dating data structure used below)
            let questions = [
                Question(questionText: "What is the speed limit in urban areas?", options: ["50 km/h", "80 km/h", "30 km/h"], correctAnswer: "50 km/h"),
                Question(questionText: "What does a red traffic light signify?", options: ["Go", "Stop", "Caution"], correctAnswer: "Stop")
            ]
            DispatchQueue.main.async {
                completion(questions)
            }
        }
    }
}