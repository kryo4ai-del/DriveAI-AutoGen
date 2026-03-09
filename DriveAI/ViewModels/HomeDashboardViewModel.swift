import SwiftUI
import Combine

class HomeDashboardViewModel: ObservableObject {
    @Published var user: User?
    
    init() {
        loadUserData()
    }
    
    func loadUserData() {
        if let data = UserDefaults.standard.data(forKey: AppConfig.Keys.userData),
           let loadedUser = try? JSONDecoder().decode(User.self, from: data) {
            user = loadedUser
        } else {
            user = nil
        }
    }
}