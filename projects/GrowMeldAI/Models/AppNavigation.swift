import SwiftUI

// MARK: - App Route

enum AppRoute: Hashable {
    case home
    case detail(String)
    case settings
}

// MARK: - Environment Key

private struct NavigateKey: EnvironmentKey {
    static let defaultValue: (AppRoute) -> Void = { _ in }
}

extension EnvironmentValues {
    var navigate: (AppRoute) -> Void {
        get { self[NavigateKey.self] }
        set { self[NavigateKey.self] = newValue }
    }
}

// MARK: - App Navigation

struct AppNavigation: View {
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            HomeView()
                .environment(\.navigate, { route in
                    navigationPath.append(route)
                })
                .navigationDestination(for: AppRoute.self) { route in
                    destination(route)
                }
        }
    }

    @ViewBuilder
    private func destination(_ route: AppRoute) -> some View {
        switch route {
        case .home:
            HomeView()
        case .detail(let id):
            DetailPlaceholderView(id: id)
        case .settings:
            SettingsPlaceholderView()
        }
    }
}

// MARK: - Placeholder Views (replace with real views as available)

private struct DetailPlaceholderView: View {
    let id: String

    var body: some View {
        Text("Detail: \(id)")
            .navigationTitle("Detail")
    }
}

private struct SettingsPlaceholderView: View {
    var body: some View {
        Text("Settings")
            .navigationTitle("Settings")
    }
}

// MARK: - HomeView Stub (only if not defined elsewhere)

#if !HOMVIEW_DEFINED
struct HomeView: View {
    var body: some View {
        Text("Home")
            .navigationTitle("Home")
    }
}
#endif