// Models/Question.swift
   struct Question: Identifiable, Codable {
       let id: UUID
       let text: String
       let options: [Answer]
       let correctAnswerId: UUID
       let explanation: String

       private enum CodingKeys: String, CodingKey {
           case id, text, options, correctAnswerId, explanation
       }
   }

   // Models/Answer.swift
   struct Answer: Identifiable, Codable {
       let id: UUID
       let text: String
   }