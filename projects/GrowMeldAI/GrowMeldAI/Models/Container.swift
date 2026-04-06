class Container {
    static let shared = Container()
    private var factories: [String: () -> Any] = [:]
    
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        factories[String(describing: type)] = factory
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        guard let factory = factories[String(describing: type)] as? () -> T else {
            fatalError("No factory registered for \(type)")
        }
        return factory()
    }
}

// Setup in AppDelegate
func setupDependencies() {
    let database = DatabaseManager(path: .documentsDirectory)
    
    Container.shared.register(DatabaseManager.self) { database }
    Container.shared.register(QuestionRepository.self) {
        LocalQuestionRepository(database: database)
    }
    Container.shared.register(ExamService.self) {
        ExamService(questionRepo: Container.shared.resolve(QuestionRepository.self))
    }
}