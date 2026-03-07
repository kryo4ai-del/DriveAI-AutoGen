// Example of a function in LocalDataService to fetch question category
   func getCategory(for questionId: UUID) -> String? {
       // Implement logic to fetch the category based on the questionId
   }

// ---

guard let data = UserDefaults.standard.data(forKey: storageKey) else {
       // Handle error gracefully
       return []
   }

// ---

private func categorizePerformance(answers: [QuestionAnswer]) -> [CategoryPerformance] {
       var categoryDict = [String: (total: Int, correct: Int)]()
       
       for answer in answers {
           let category = getCategory(for: answer.questionId) ?? "Unknown"
           updateCategoryStats(for: category, isCorrect: answer.isCorrect, in: &categoryDict)
       }
       
       return categoryDict.map { 
           createCategoryPerformance(from: $0)
       }
   }
   
   private func updateCategoryStats(for category: String, isCorrect: Bool, in dict: inout [String: (total: Int, correct: Int)]) {
       // Logic to update stats
   }
   
   private func createCategoryPerformance(from entry: (key: String, value: (total: Int, correct: Int))) -> CategoryPerformance {
       // Logic to create category performance object
   }

// ---

override func setUp() {
    super.setUp()
    localDataServiceMock = LocalDataServiceMock()
    questionAnalysisService = QuestionAnalysisService(localDataService: localDataServiceMock)

    // Optionally, populate mock data
    localDataServiceMock.addCategory(for: UUID(), category: "Traffic Signs")
    localDataServiceMock.addMockQuestions([Question(id: UUID(), text: "What does a stop sign mean?", category: "Traffic Signs", options: ["Stop", "Go"], correctOption: 0)])
}