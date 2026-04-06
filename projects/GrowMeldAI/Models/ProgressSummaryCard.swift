struct ProgressSummaryCard: View {
    var body: some View {
        VStack { ... }
            .padding()  // ❌ Only 16pt padding — entire card is ~80×60 on iPhone SE
            // Touch target < 44×44 pt (Apple minimum)
}
