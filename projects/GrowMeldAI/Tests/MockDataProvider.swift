// Services/Data/MockDataProvider.swift
enum MockDataProvider {
    static let questions: [Question] = [
        Question(
            id: "q001",
            categoryID: "signs",
            text: "Was bedeutet ein rotes Stoppschild?",
            options: ["Weiterfahren", "Anhalten", "Vorsicht"],
            correctAnswer: "Anhalten",
            explanation: "Ein rotes Stoppschild bedeutet, dass Sie anhalten müssen.",
            imageURL: nil,
            difficulty: .easy
        ),
        Question(
            id: "q002",
            categoryID: "signs",
            text: "Welche Farbe hat ein Vorfahrtsschild?",
            options: ["Rot", "Gelb", "Weiß"],
            correctAnswer: "Weiß",
            explanation: "Vorfahrtsschilder sind weiß mit rotem Rand.",
            imageURL: nil,
            difficulty: .easy
        ),
        // ... minimum 100+ questions across 4 categories
    ]
}