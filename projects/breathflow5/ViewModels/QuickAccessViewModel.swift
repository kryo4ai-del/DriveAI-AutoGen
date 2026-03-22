import SwiftUI

class QuickAccessViewModel: ObservableObject {
       @Published var navigationPath: SwiftUI.NavigationPath?
       @Published var isLoading = false
       @Published var error: QuickAccessError?
       
       private let service: QuickAccessService
       
       init(service: QuickAccessService) {
           self.service = service
       }
       
       func tappedQuickAccess() async {
           // Call service, update @Published properties
       }
   }