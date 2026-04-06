class CloudFunctionsService: NSObject, ObservableObject {
      func submitExamSession(_ answers: [QuestionAnswer]) async throws -> ExamResult
      func getPersonalizedCurriculum() async throws -> [Question]
      func syncProgress() async throws -> UserProgress
  }