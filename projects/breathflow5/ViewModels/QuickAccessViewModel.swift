import SwiftUI

protocol QuickAccessServiceProtocol {
    func fetchQuickAccess() async throws
}

class QuickAccessViewModel: ObservableObject {
       @Published var navigationPath: SwiftUI.NavigationPath?
       @Published var isLoading = false
       @Published var error: QuickAccessError?
       
       private let service: any QuickAccessServiceProtocol
       
       init(service: any QuickAccessServiceProtocol) {
           self.service = service
       }
       
       func tappedQuickAccess() async {
           // Call service, update @Published properties
       }
   }