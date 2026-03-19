// File: com/driveai/askfin/data/models/TrainingMode.kt
package com.driveai.askfin.data.models

enum class TrainingMode(val description: String) {
    DAILY("Tägliche Trainingseinheit"),
    TOPIC("Themenbasiertes Training"),
    WEAKNESS("Schwachstellen trainieren")
}