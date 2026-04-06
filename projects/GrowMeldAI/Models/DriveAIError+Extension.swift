enum DriveAIError: Error {
    case testError(message: String = "Test error")
}

#if !DEBUG
extension DriveAIError {
    @available(*, unavailable, message: "testError only available in DEBUG builds")
    static func testError(_ message: String) -> DriveAIError { fatalError() }
}
#endif