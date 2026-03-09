struct QuestionsForCategoryView: View {
    let category: QuestionCategory
    
    var body: some View {
        VStack {
            Text("Fragen für \(category.name)")
                .font(.largeTitle)
                .padding()
            Text(LocalizedStrings.questionsInstruction) // Instruction using localization
                .font(.subheadline)
                .padding()
            Button(action: {
                // Logic to navigate to the questions associated with the selected category
            }) {
                Text(LocalizedStrings.startButtonTitle) // Button title using localization
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}