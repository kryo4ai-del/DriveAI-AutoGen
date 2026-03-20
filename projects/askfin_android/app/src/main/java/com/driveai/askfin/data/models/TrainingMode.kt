// File: com.driveai.askfin/data/models/TrainingMode.kt
package com.driveai.askfin.data.models

enum class TrainingMode {
    LEARNER,      // Learn mode: study with explanations
    PRACTICE,     // Practice mode: timed questions
    EXAM,         // Exam mode: full test simulation
    REVIEW        // Review mode: revisit incorrect answers
}