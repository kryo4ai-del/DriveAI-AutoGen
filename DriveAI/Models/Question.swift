struct Question: Identifiable {
       let id: UUID
       let text: String
       let options: [String]
       let correctAnswer: String
       let explanation: String? // Ensure explanations are present
   }