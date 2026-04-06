extension DriveAIApp {
    var body: some Scene {
        WindowGroup {
            // ...
            .environment(\.localDataService, LocalDataService.shared)
            .environment(\.progressService, ProgressService.shared)
            .environment(\.userService, UserService.shared)
        }
    }
}