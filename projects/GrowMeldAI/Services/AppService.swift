// ❌ DON'T DO THIS
class AppService {  // Does everything, hard to test
    func loadQuestions() { }
    func saveProgress() { }
    func startExam() { }
    func encryptBackup() { }
}

// ✅ DO THIS
class QuestionService { func loadQuestions() { } }
class ProgressService { func saveProgress() { } }
class ExamModeService { func startExam() { } }