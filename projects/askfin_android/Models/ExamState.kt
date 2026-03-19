enum class ExamState {
    NOT_STARTED, IN_PROGRESS, COMPLETED, REVIEWING
}
// No validation that state follows: NOT_STARTED → IN_PROGRESS → COMPLETED → REVIEWING