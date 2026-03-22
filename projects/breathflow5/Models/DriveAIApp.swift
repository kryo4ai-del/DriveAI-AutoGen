@main
struct DriveAIApp: App {
    // Initialize all dependencies
    let exerciseSelectionService = ...
    let quizProgressService = ...
    let authService = ...
    let analyticsService = ...
    
    // Create QuickAccess module
    lazy var quickAccessService = QuickAccessModuleFactory.makeQuickAccessService(...)
    lazy var quickAccessCoordinator = QuickAccessModuleFactory.makeCoordinator(...)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(quickAccessCoordinator)
        }
    }
}