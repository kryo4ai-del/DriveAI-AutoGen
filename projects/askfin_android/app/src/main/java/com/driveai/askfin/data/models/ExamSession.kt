package com.driveai.askfin.data.models

data class ExamSession(
    val id: String,
    val answers: Map<String, Answer> = emptyMap(),
    val state: ExamState = ExamState.NOT_STARTED
) {
    init {
        require(id.isNotBlank() && answers.keys.all { ... }) { }
    }
    val isCompleted: Boolean get() = state in setOf(COMPLETED, REVIEWING)
}