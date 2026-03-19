// com/driveai/askfin/ui/utils/AccessibilityLabels.kt

object AccessibilityLabels {
    fun question(text: String) = "Question: $text"
    fun answer(text: String) = "Answer: $text"
    fun answerWithResult(text: String, isCorrect: Boolean) = 
        "Answer: $text. ${if (isCorrect) "Correct" else "Incorrect"}"
    fun progress(current: Int, total: Int) = "Question $current of $total"
    fun loading(msg: String = "Loading") = "$msg..."
    fun error(msg: String) = "Error: $msg"
}