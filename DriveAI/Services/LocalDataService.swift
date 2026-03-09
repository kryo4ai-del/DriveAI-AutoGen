class LocalDataService {
    func fetchQuestionCategories() -> [QuestionCategory] {
        return [
            QuestionCategory(id: UUID(), name: "Verkehrszeichen", questionCount: 15),
            QuestionCategory(id: UUID(), name: "Vorfahrtsrecht", questionCount: 10),
            QuestionCategory(id: UUID(), name: "Bußgelder", questionCount: 5)
        ]
    }
}