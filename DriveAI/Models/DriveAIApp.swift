@main
struct DriveAIApp: App {
    @StateObject private var progressVM = ProgressViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                DashboardScreen()
                    .environmentObject(progressVM)
            }
        }
    }
}