import Foundation

class SampleValidationViewModel: ObservableObject {
    @Published var questionResults: [ValidationResult] = []
    @Published var signResults: [ValidationResult] = []
    @Published var isRunningSignTests = false

    private let service = SampleValidationService()

    var totalRun: Int     { questionResults.count + signResults.count }
    var totalPassed: Int  { passedQuestions + passedSigns }
    var passedQuestions: Int { questionResults.filter { $0.overallPassed }.count }
    var passedSigns: Int     { signResults.filter    { $0.overallPassed }.count }
    var categoryMatchCount: Int { questionResults.filter { $0.categoryMatches }.count }

    func runAll() {
        questionResults = service.runQuestionValidation()
        runSignTests()
    }

    private func runSignTests() {
        isRunningSignTests = true
        service.runTrafficSignValidation { [weak self] results in
            self?.signResults = results
            self?.isRunningSignTests = false
        }
    }
}
