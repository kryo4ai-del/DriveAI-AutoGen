protocol QuestionAnalysisServiceProtocol {
    func analyzeResults(answers: [QuestionAnswer]) -> Result<AnalysisResult, Error>
    func fetchPreviousAnalysis() -> Result<[AnalysisResult], Error>
    func storeAnalysisResults(_ result: AnalysisResult) -> Result<Void, Error>
    func fetchRelatedQuestions(for categories: [String]) -> [Question] // Example: Should integrate this with LocalDataService
}