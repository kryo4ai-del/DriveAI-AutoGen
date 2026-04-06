// Core/Navigation/Router.swift
import SwiftUI

@MainActor
final class Router: ObservableObject {
    @Published var path = NavigationPath()

    enum Destination: Hashable {
        case onboarding
        case dashboard
        case questions(categoryId: String)
        case exam
        case profile
        case result(ExamResult)
    }

    func navigate(to destination: Destination) {
        path.append(destination)
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}