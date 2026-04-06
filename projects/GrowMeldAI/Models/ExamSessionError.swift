// ExamSession has:
enum ExamSessionError: Error {
    case invalidState
    case questionIndexOutOfBounds
}

// But other models have no errors
// Result: ViewModels don't know what can fail