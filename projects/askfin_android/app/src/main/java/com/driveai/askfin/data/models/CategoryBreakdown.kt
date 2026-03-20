package com.driveai.askfin.data.models

data class CategoryBreakdown(val correct: Int, val total: Int) {
    // Missing: require(correct >= 0 && correct <= total)
}