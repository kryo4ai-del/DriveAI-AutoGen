// File: com/driveai/askfin/data/models/Answer.kt
package com.driveai.askfin.data.models

data class Answer(
    val id: String,
    val text: String
) {
    init {
        require(id.isNotBlank()) { "Answer ID cannot be blank" }
        require(text.isNotBlank()) { "Answer text cannot be blank" }
    }
}