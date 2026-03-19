enum class QuestionCategory(
    val displayName: String,
    val examPercentage: Int  // % of 30-question exam
) {
    VORFAHRT("Vorfahrt", 25),
    VERKEHRSZEICHEN("Verkehrszeichen", 30),
    TECHNIK("Technik", 10),
    VERHALTEN("Verhalten", 15),
    UMWELT_ENERGI("Umwelt & Energie", 10),
    STRAFEN_VERWARN("Strafen & Verwarnungsgelder", 5),
    SICHERHEIT("Sicherheit", 3),
    FAHRPHYSIK("Fahrphysik", 1),
    VERKEHRSRECHTLICH("Verkehrsrechtliches", 1),
    AUTOMATISIERUNG("Automatisierung", 0);

    companion object {
        fun fromString(value: String): QuestionCategory? =
            values().find { it.name.equals(value, ignoreCase = true) }
        
        fun validateExamDistribution() {
            val total = values().sumOf { it.examPercentage }
            require(total == 100) { 
                "Exam percentages must sum to 100%, got $total" 
            }
        }
        
        init { validateExamDistribution() }  // Fail fast on typo
    }
}