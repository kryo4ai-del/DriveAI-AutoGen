// NavigationRouter.swift
import Foundation
import SwiftUI

/// Navigation state management for DriveAI app
final class NavigationRouter: ObservableObject {
    enum Route: Hashable {
        case home
        case categoryDetail(String)
        case questionDetail(String, String) // categoryId, questionId
        case examSimulation
        case settings
        case statistics
        case signMemoryGame
    }

    @Published var path = NavigationPath()

    func navigate(to route: Route) {
        path.append(route)
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    // Thread-safe navigation
    func safeNavigate(to route: Route) {
        DispatchQueue.main.async { [weak self] in
            self?.path.append(route)
        }
    }
}

/// View modifier for navigation
struct RouteViewModifier: ViewModifier {
    @EnvironmentObject var router: NavigationRouter

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: NavigationRouter.Route.self) { route in
                switch route {
                case .home:
                    HomeView()
                case .categoryDetail(let categoryId):
                    CategoryDetailView(categoryId: categoryId)
                case .questionDetail(let categoryId, let questionId):
                    QuestionDetailView(categoryId: categoryId, questionId: questionId)
                case .examSimulation:
                    ExamSimulationView()
                case .settings:
                    SettingsView()
                case .statistics:
                    StatisticsView()
                case .signMemoryGame:
                    SignMemoryGameView()
                }
            }
    }
}

extension View {
    func withNavigationRoutes() -> some View {
        modifier(RouteViewModifier())
    }
}