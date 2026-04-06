import Foundation

enum AppNavigationPath: Hashable {
    case categoryBrowser
    case questionFlow(categoryId: UUID)
    case examMode
    case examResults(score: Int, total: Int, passed: Bool)
}