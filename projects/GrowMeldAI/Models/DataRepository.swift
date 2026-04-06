protocol DataRepository {
    func fetchQuestions(categoryID: String) async -> [Question]
    func fetchCategories() async -> [Category]
    func getQuestion(id: String) async -> Question?
}
