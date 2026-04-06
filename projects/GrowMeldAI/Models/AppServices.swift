// Services/AppServices.swift

/// Single protocol aggregating all service dependencies
protocol AppServices: Sendable {
    var data: DataServiceProtocol { get }
    var preferences: PreferencesServiceProtocol { get }
    var motivation: MotivationServiceProtocol { get }
    var exam: ExamServiceProtocol { get }
}

/// Concrete implementation
class DefaultAppServices: AppServices, Sendable {
    let data: DataServiceProtocol
    let preferences: PreferencesServiceProtocol
    let motivation: MotivationServiceProtocol
    let exam: ExamServiceProtocol
    
    init() {
        self.data = LocalDataService()
        self.preferences = UserPreferencesService()
        self.motivation = MotivationService()
        self.exam = ExamSimulationService(data: data, preferences: preferences)
    }
}

// Testing: Single mock for all services
class MockAppServices: AppServices {
    let data: DataServiceProtocol
    let preferences: PreferencesServiceProtocol
    let motivation: MotivationServiceProtocol
    let exam: ExamServiceProtocol
    
    init() {
        self.data = MockDataService()
        self.preferences = MockPreferencesService()
        self.motivation = MockMotivationService()
        self.exam = MockExamService()
    }
}

// App initialization
@main