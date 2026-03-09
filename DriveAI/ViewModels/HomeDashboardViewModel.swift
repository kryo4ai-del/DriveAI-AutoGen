import SwiftUI
import Combine

class HomeDashboardViewModel: ObservableObject {
    @Published var user: User?
    
    init() {
        loadUserData()
    }
    
    func loadUserData() {
        if let data = UserDefaults.standard.data(forKey: "userData"),
           let loadedUser = try? JSONDecoder().decode(User.self, from: data) {
            user = loadedUser
        } else {
            // You may consider redirecting to Onboarding
            user = nil // make clear no user data found
        }
    }
}