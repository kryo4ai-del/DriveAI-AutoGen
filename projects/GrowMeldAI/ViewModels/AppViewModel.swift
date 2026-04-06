import Foundation
import Combine

@MainActor
class AppViewModel: ObservableObject {
    @Published var isOnboarded = false
    init() {
        isOnboarded = UserDefaults.standard.bool(forKey: "isOnboarded")
    }
}
