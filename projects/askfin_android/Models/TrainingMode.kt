// File: com/driveai/askfin/data/models/TrainingMode.kt
package com.driveai.askfin.data.models

enum class TrainingMode(val displayName: String, val description: String) {
    DAILY(
        displayName = "Tägliches Training",
        description = "Löse täglich neue Fragen aus verschiedenen Kategorien"
    ),
    TOPIC(
        displayName = "Thementraining",
        description = "Konzentriere dich auf eine spezifische Kategorie"
    ),
    WEAKNESS(
        displayName = "Schwachstellen",
        description = "Trainiere Fragen, bei denen du häufig Fehler machst"
    )
}