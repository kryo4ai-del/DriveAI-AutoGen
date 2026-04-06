protocol QuestionLinkerServiceProtocol {
    func getRelatedQuestions(for signID: String, limit: Int) -> [Question]
    func getSignMetadata(signID: String) -> TrafficSign?
}

@MainActor
class QuestionLinkerService: QuestionLinkerServiceProtocol {
    
    private let localDataService: LocalDataService
    private var queryCache: [String: [Question]] = [:]
    private var metadataCache: [String: TrafficSign] = [:]
    
    init(localDataService: LocalDataService) {
        self.localDataService = localDataService
    }
    
    func getRelatedQuestions(for signID: String, limit: Int) -> [Question] {
        // Check cache first
        if let cached = queryCache[signID] {
            return Array(cached.prefix(limit))
        }
        
        // Query database
        let questions = localDataService.getQuestionsForSign(signID)
        
        // Cache result
        queryCache[signID] = questions
        
        return Array(questions.prefix(limit))
    }
    
    func getSignMetadata(signID: String) -> TrafficSign? {
        if let cached = metadataCache[signID] {
            return cached
        }
        
        let metadata = localDataService.getSignMetadata(signID)
        if let metadata = metadata {
            metadataCache[signID] = metadata
        }
        
        return metadata
    }
}