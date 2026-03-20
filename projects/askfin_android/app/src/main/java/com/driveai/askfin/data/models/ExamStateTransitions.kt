package com.driveai.askfin.data.models

// Add state machine definition:
object ExamStateTransitions {
    private val validTransitions = mapOf(
        ExamState.NOT_STARTED to listOf(ExamState.IN_PROGRESS),
        ExamState.IN_PROGRESS to listOf(ExamState.COMPLETED),
        ExamState.COMPLETED to listOf(ExamState.REVIEWING),
        ExamState.REVIEWING to listOf() // terminal
    )
    
    fun isValidTransition(from: ExamState, to: ExamState): Boolean =
        validTransitions[from]?.contains(to) ?: false
}