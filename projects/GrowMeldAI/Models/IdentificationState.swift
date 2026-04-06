// IdentificationResult declared in Models/IdentificationResult.swift

enum IdentificationState {
    case waiting          // Ready for input
    case processing       // API/DB call in progress
    case completed(IdentificationResult)  // Success with data
    case failed(Error)    // Error state
}
