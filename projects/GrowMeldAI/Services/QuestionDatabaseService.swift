class QuestionDatabaseService: LocalDataService {
    static let shared = QuestionDatabaseService()
    
    private let decoder = JSONDecoder()
    private let cacheQueue = DispatchQueue(
        label: "com.driveai.question-cache",
        attributes: .concurrent
    )
    private var _cachedQuestions: [Question]?
    
    private var cachedQuestions: [Question]? {
        get {
            cacheQueue.sync { _cachedQuestions }
        }
        set {
            cacheQueue.async(flags: .barrier) {
                self._cachedQuestions = newValue
            }
        }
    }
    
    nonisolated private init() {}
    
    func fetchAllQuestions() async throws -> [Question] {
        if let cached = cachedQuestions {
            return cached
        }
        
        guard let url = Bundle.main.url(
            forResource: "questions_de",
            withExtension: "json"
        ) else {
            return [Question.mock]
        }
        
        do {
            let data = try Data(contentsOf: url)
            let questions = try decoder.decode([Question].self, from: data)
            self.cachedQuestions = questions // Atomic update via barrier
            return questions
        } catch {
            throw LocalDataError.decodingError
        }
    }
}