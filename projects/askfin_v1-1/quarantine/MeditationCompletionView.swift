import SwiftUI
// In MeditationCompletionView — replace dismiss with path manipulation:
// Accept a popToRoot closure:
struct MeditationCompletionView: View {
    @ObservedObject var viewModel: MeditationCompletionViewModel
    let onDismissAll: () -> Void
    
    // ...
    
    Button("Fertig") {
        onDismissAll()
    }
}

// In MeditationActiveView:
MeditationCompletionView(viewModel: vm, onDismissAll: {
    // pop Active and Completion both
    presentationMode.wrappedValue.dismiss()
})

// But this only dismisses Active, leaving Completion's dismiss uncalled.