@main
struct DriveAIApp: App {
    let container = AppContainer()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.readinessCalculator, container.readinessCalculator)
                .environment(\.trendAnalyzer, container.trendAnalyzer)
                .environment(\.predictionEngine, container.predictionEngine)
        }
    }
}