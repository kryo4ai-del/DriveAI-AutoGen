import SwiftUI

class AppThemeManager: ObservableObject {
    static let shared = AppThemeManager()
    @Published var isDarkMode = false
}
