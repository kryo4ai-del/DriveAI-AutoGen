// ❌ INACCESSIBLE
struct PreExamConfidenceBoost: View {
    let achievements: [EpisodicMemory]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Remember Your Wins")  // ⚠️ Not marked as heading
            ScrollView {
                ForEach(achievements) { achievement in
                    HStack {
                        Text(achievement.metadata.emoji)
                        Text(achievement.metadata.detail)  // ⚠️ No context
                    }
                }
            }
            Button("I'm Ready") { dismiss() }  // ⚠️ No hint about keyboard shortcut
        }
        .background(Color.black.opacity(0.4))  // ⚠️ Trap focus?
    }
}