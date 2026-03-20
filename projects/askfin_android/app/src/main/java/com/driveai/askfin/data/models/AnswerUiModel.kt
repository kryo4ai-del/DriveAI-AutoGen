package com.driveai.askfin.data.models

data class AnswerUiModel(
    val id: String,
    val displayText: String,
    val isCorrect: Boolean
)

// In AnswerButton, accept AnswerUiModel instead of Answer