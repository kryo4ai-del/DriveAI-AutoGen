struct QuestionScreenView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            QuestionScreenView(question: mockQuestion)
                .environment(\.sizeCategory, .extraSmall)
            
            QuestionScreenView(question: mockQuestion)
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
        }
    }
}