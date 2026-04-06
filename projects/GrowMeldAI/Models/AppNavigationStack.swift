import SwiftUI

// MARK: - Navigation Stack Controller

final class NavigationStackController: ObservableObject {
    @Published var path: SwiftUI.NavigationPath = SwiftUI.NavigationPath()

    func popToRoot() {
        path = SwiftUI.NavigationPath()
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}

// MARK: - Root Navigation Coordinator

struct AppNavigationStack: View {
    @StateObject private var navStack = NavigationStackController()

    var body: some View {
        SwiftUI.NavigationStack(path: $navStack.path) {
            Text("Dashboard")
                .navigationTitle("Dashboard")
        }
        .environmentObject(navStack)
    }
}