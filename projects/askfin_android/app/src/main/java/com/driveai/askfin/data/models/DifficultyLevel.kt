package com.driveai.askfin.data.models

enum class DifficultyLevel {
    EASY, MEDIUM, HARD
}

fun setDifficultyFilter(difficulty: DifficultyLevel?) {
    _selectedDifficulty.value = difficulty
}