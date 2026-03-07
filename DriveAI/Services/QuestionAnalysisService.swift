import Foundation

class QuestionAnalysisService: QuestionAnalysisServiceProtocol {
    private let storageKey = "QuestionAnalysisResults"
    private let localDataService: LocalDataService

    init(localDataService: LocalDataService) {
        self.localDataService = localDataService
    }
    
    func analyzeResults(answers: [QuestionAnswer]) -> Result<AnalysisResult, Error> {
        let totalQuestions = answers.count
        let correctAnswers = answers.filter { $0.isCorrect }.count
        let incorrectAnswers = totalQuestions - correctAnswers
        
        let breakdown = categorizePerformance(answers: answers)
        
        let result = AnalysisResult(
            answeredDate: Date(),
            totalQuestions: totalQuestions,
            correctAnswers: correctAnswers,
            incorrectAnswers: incorrectAnswers,
            breakdown: breakdown
        )
        
        // Attempt to store results and return based on success
        let storeResult = storeAnalysisResults(result)
        switch storeResult {
        case .success:
            return .success(result)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func fetchPreviousAnalysis() -> Result<[AnalysisResult], Error> {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return .failure(NSError(domain: "DataError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No previous analysis found"]))
        }
        let decoder = JSONDecoder()
        do {
            let results = try decoder.decode([AnalysisResult].self, from: data)
            return .success(results)
        } catch {
            return .failure(error)
        }
    }
    
    func storeAnalysisResults(_ result: AnalysisResult) -> Result<Void, Error> {
        var results = (try? fetchPreviousAnalysis().get()) ?? []
        results.append(result)
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(results)
            UserDefaults.standard.set(data, forKey: storageKey)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func fetchRelatedQuestions(for categories: [String]) -> [Question] {
        return localDataService.fetchQuestions(for: categories) // Assuming this fetches related questions.
    }
    
    private func categorizePerformance(answers: [QuestionAnswer]) -> [CategoryPerformance] {
        var categoryDict = [String: (total: Int, correct: Int)]()
        
        for answer in answers {
            let category = localDataService.getCategory(for: answer.questionId) ?? "Unknown"
            updateCategoryStats(for: category, isCorrect: answer.isCorrect, in: &categoryDict)
        }
        
        return categoryDict.map { 
            createCategoryPerformance(from: $0)
        }
    }
    
    private func updateCategoryStats(for category: String, isCorrect: Bool, in dict: inout [String: (total: Int, correct: Int)]) {
        if dict[category] == nil {
            dict[category] = (total: 0, correct: 0)
        }
        
        dict[category]?.total += 1
        if isCorrect {
            dict[category]?.correct += 1
        }
    }
    
    private func createCategoryPerformance(from entry: (key: String, value: (total: Int, correct: Int))) -> CategoryPerformance {
        let (category, (total, correct)) = entry
        return CategoryPerformance(category: category, total: total, correct: correct, incorrect: total - correct)
    }
}