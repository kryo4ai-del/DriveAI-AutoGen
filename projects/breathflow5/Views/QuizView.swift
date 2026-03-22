// DON'T do this
struct QuizView: View {
    @State var currentQuestion: Question  // ← Local only, lost on view rebuild
    @State var score: Int                 // ← Shared state scattered
    
    // Score not persisted if view dismisses
}