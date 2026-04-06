import Foundation

enum AppNavigationDestination: Hashable {
    case categoryBrowser
    case questionFlow(categoryId: UUID)
    case examMode
    case examResults(score: Int, total: Int, passed: Bool)
}