import SwiftUI

// MARK: - Navigation Stack Controller

final class NavigationStackController: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()

    func popToRoot() {
        path = NavigationPath()
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
        NavigationStack(path: $navStack.path) {
            Text("Dashboard")
                .navigationTitle("Dashboard")
        }
        .environmentObject(navStack)
    }
}