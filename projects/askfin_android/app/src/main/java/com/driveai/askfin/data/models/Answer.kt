// File: com.driveai.askfin/data/models/Answer.kt
package com.driveai.askfin.data.models

import com.driveai.askfin.data.models.validators.ValidationRules

data class Answer(
    val id: String,
    val text: String,
    val isCorrect: Boolean,
    val explanation: String? = null
) {
    init {
        ValidationRules.validateId(id)
        ValidationRules.validateText(text)
    }
}