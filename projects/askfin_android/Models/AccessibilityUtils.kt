// com.driveai.askfin.ui.utils/AccessibilityUtils.kt

object AccessibilityUtils {
    fun questionDescription(text: String): String = "Question: $text"
    fun answerDescription(text: String, isCorrect: Boolean?, isRevealed: Boolean): String {
        return buildString {
            append("Answer: $text")
            if (isRevealed) {
                append(". ${if (isCorrect == true) "Correct" else "Incorrect"}")
            }
        }
    }
    fun explanationDescription(text: String?): String = "Explanation: ${text ?: "No details provided"}"
    fun progressDescription(current: Int, total: Int): String = "Question $current of $total"
}