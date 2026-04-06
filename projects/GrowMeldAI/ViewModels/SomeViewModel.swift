// Every ViewModel does this:
class SomeViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // ...
        } catch {
            self.error = error.localizedDescription
        }
    }
}