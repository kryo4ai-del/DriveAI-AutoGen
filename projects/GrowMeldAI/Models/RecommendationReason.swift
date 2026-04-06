enum RecommendationReason {
    case weakCategory = "Du hast hier noch Lücken—lass uns diese schließen"
    case spacedRepetition = "Zeit für eine Auffrischung—das verfestigt dein Wissen"
    case newCategory = "Neuer Bereich—lass dich überraschen"
}

// In LocalDataService
func getNextQuestion(for user: UserProgress) -> (question: Question, reason: RecommendationReason)