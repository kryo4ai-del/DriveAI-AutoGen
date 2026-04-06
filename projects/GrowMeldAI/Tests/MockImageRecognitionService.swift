// Tests/Mocks/MockImageRecognitionService.swift
class MockImageRecognitionService: ImageRecognitionService {
  var identifyResult: Result<IdentificationResult, ImageRecognitionError> = 
    .success(IdentificationResult.mock)
  
  func identify(request: IdentificationRequest) async throws -> IdentificationResult {
    try identifyResult.get()
  }
}

// Tests/Fixtures/IdentificationResult+Mock.swift
extension IdentificationResult {
  static var mock: IdentificationResult {
    IdentificationResult(
      name: "Stop Sign",
      confidence: 0.95,
      category: .trafficSign,
      description: "Red octagonal sign"
    )
  }
}