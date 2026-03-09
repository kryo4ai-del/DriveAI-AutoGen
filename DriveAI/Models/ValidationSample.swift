import Foundation

enum ValidationDomain: String {
    case question    = "Question"
    case trafficSign = "Traffic Sign"
}

struct ValidationSample: Identifiable {
    let id: UUID
    let domain: ValidationDomain
    let title: String
    let inputDescription: String    // what was fed in
    let expectedResult: String      // expected sign name or answer key
    let expectedCategory: String    // expected topic / sign category
    let expectedConfidenceMin: Double
    let explanation: String

    init(id: UUID = UUID(), domain: ValidationDomain, title: String,
         inputDescription: String, expectedResult: String,
         expectedCategory: String, expectedConfidenceMin: Double, explanation: String) {
        self.id = id
        self.domain = domain
        self.title = title
        self.inputDescription = inputDescription
        self.expectedResult = expectedResult
        self.expectedCategory = expectedCategory
        self.expectedConfidenceMin = expectedConfidenceMin
        self.explanation = explanation
    }
}

struct ValidationResult: Identifiable {
    let id = UUID()
    let sample: ValidationSample
    let actualResult: String
    let actualCategory: String
    let actualConfidence: Double
    let actualExplanation: String
    let isLiveTested: Bool          // true = ran through a real service

    var resultMatches: Bool   { actualResult   == sample.expectedResult }
    var categoryMatches: Bool { actualCategory == sample.expectedCategory }
    var confidenceOk: Bool    { actualConfidence >= sample.expectedConfidenceMin }
    var overallPassed: Bool   { resultMatches && confidenceOk }
}
