import SwiftUI

@main
struct DriveAIApp: App {
    @State private var showLaunch = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                AppNavigationView()
                    .preferredColorScheme(.dark)

                if showLaunch {
                    LaunchScreenView()
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                withAnimation(.easeOut(duration: 0.55)) {
                                    showLaunch = false
                                }
                            }
                        }
                }
            }
        }
    }
}
