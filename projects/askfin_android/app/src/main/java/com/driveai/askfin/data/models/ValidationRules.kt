// File: com.driveai.askfin/data/models/validators/ValidationRules.kt
package com.driveai.askfin.data.models
import java.time.Instant

object ValidationRules {
    const val MIN_ANSWER_COUNT = 1
    const val MIN_CORRECT_ANSWERS = 1
    const val MIN_TIME_LIMIT = 1
    const val TIMESTAMP_SKEW_TOLERANCE_SECONDS = 5L
    const val MIN_ID_LENGTH = 1
    const val MIN_TEXT_LENGTH = 1
    
    fun validateId(id: String, fieldName: String = "ID"): String {
        require(id.isNotBlank()) { "$fieldName cannot be blank" }
        return id
    }
    
    fun validateText(text: String, fieldName: String = "text"): String {
        require(text.isNotBlank()) { "$fieldName cannot be blank" }
        return text
    }
    
    fun validatePositiveInt(value: Int?, fieldName: String): Int? {
        if (value != null) {
            require(value > 0) { "$fieldName must be positive, got $value" }
        }
        return value
    }
    
    fun validateAnswers(answers: List<*>): List<*> {
        require(answers.isNotEmpty()) { "Must have at least one answer" }
        return answers
    }
    
    fun validateCorrectAnswerCount(count: Int, enforceExactlyOne: Boolean = false) {
        if (enforceExactlyOne) {
            require(count == 1) { "Must have exactly one correct answer, got $count" }
        } else {
            require(count >= MIN_CORRECT_ANSWERS) { "Must have at least one correct answer, got $count" }
        }
    }
    
    fun validateTimestamp(timestamp: Instant, allowFuture: Boolean = false) {
        val now = Instant.now()
        val tolerance = now.plusSeconds(TIMESTAMP_SKEW_TOLERANCE_SECONDS)
        require(timestamp <= tolerance) { 
            "Timestamp cannot be more than $TIMESTAMP_SKEW_TOLERANCE_SECONDS seconds in the future" 
        }
    }
}