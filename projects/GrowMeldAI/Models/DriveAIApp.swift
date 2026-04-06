@main
struct DriveAIApp: App {
    @StateObject private var container = AppContainer()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container.coordinator)
                .environmentObject(container.appState)
        }
    }
}