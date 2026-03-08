import SwiftUI

@main
struct DriveAIApp: App {
    var body: some Scene {
        WindowGroup {
            HomeDashboardView()
                .environment(\.layoutDirection, .leftToRight)  // Supports right-to-left languages, if needed in future
        }
    }
}