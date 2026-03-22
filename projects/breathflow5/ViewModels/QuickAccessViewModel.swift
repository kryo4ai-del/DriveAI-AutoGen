class QuickAccessViewModel: ObservableObject {
       @Published var navigationPath: NavigationPath?
       @Published var isLoading = false
       @Published var error: QuickAccessError?
       
       private let service: QuickAccessService
       
       func tappedQuickAccess() async {
           // Call service, update @Published properties
       }
   }