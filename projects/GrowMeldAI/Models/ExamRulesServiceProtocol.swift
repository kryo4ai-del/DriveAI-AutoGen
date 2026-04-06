protocol ExamRulesServiceProtocol {
    func isPassingScore(_ correctAnswers: Int) -> Bool
    func passingThreshold() -> Int  // 14
    func totalQuestions() -> Int    // 30
    func passPercentage() -> Double // 0.4667
}

class ExamRulesService: ExamRulesServiceProtocol {
    static let totalExamQuestions = 30
    static let passingThreshold = 14  // 46.67%
    
    func isPassingScore(_ correctAnswers: Int) -> Bool {
        return correctAnswers >= Self.passingThreshold
    }
    
    func passingThreshold() -> Int {
        return Self.passingThreshold
    }
    
    func totalQuestions() -> Int {
        return Self.totalExamQuestions
    }
    
    func passPercentage() -> Double {
        return Double(Self.passingThreshold) / Double(Self.totalExamQuestions)
    }
}