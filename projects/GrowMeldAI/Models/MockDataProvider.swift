import Foundation

enum MockDataProvider {
    static let questions: [QuizQuestion] = [
        QuizQuestion(
            id: "q001",
            categoryID: "signs",
            text: "Was bedeutet ein rotes Stoppschild?",
            options: ["Weiterfahren", "Anhalten", "Vorsicht"],
            correctAnswer: "Anhalten",
            explanation: "Ein rotes Stoppschild bedeutet, dass Sie anhalten müssen.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q002",
            categoryID: "signs",
            text: "Welche Farbe hat ein Vorfahrtsschild?",
            options: ["Rot", "Gelb", "Weiß"],
            correctAnswer: "Weiß",
            explanation: "Vorfahrtsschilder sind weiß mit rotem Rand.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q003",
            categoryID: "signs",
            text: "Was bedeutet ein gelbes Warndreieck?",
            options: ["Gefahr", "Parken erlaubt", "Einbahnstraße"],
            correctAnswer: "Gefahr",
            explanation: "Gelbe Warndreiecke weisen auf eine Gefahrenstelle hin.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q004",
            categoryID: "signs",
            text: "Was bedeutet das blaue Schild mit weißem Pfeil nach oben?",
            options: ["Einbahnstraße", "Vorfahrt", "Autobahn"],
            correctAnswer: "Einbahnstraße",
            explanation: "Ein blaues Schild mit weißem Pfeil nach oben zeigt eine Einbahnstraße an.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q005",
            categoryID: "signs",
            text: "Was bedeutet ein rundes rotes Schild mit weißem Balken?",
            options: ["Einfahrt verboten", "Parken verboten", "Halten verboten"],
            correctAnswer: "Einfahrt verboten",
            explanation: "Das runde rote Schild mit weißem Balken bedeutet Einfahrt verboten.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q006",
            categoryID: "signs",
            text: "Was zeigt ein blaues rundes Schild mit weißem P?",
            options: ["Parken erlaubt", "Polizei", "Privatgelände"],
            correctAnswer: "Parken erlaubt",
            explanation: "Ein blaues rundes Schild mit weißem P kennzeichnet einen Parkplatz.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q007",
            categoryID: "signs",
            text: "Was bedeutet ein Schild mit rotem Rand und schwarzem Fahrrad?",
            options: ["Fahrradweg", "Fahrräder verboten", "Fahrradstraße"],
            correctAnswer: "Fahrräder verboten",
            explanation: "Ein Schild mit rotem Rand und durchgestrichenem Fahrrad bedeutet Fahrräder verboten.",
            imageURL: nil,
            difficulty: .medium
        ),
        QuizQuestion(
            id: "q008",
            categoryID: "signs",
            text: "Was bedeutet das Zeichen 'Vorfahrt gewähren'?",
            options: ["Anhalten und Vorfahrt gewähren", "Langsam fahren", "Vorfahrt haben"],
            correctAnswer: "Anhalten und Vorfahrt gewähren",
            explanation: "Das Zeichen 'Vorfahrt gewähren' bedeutet, dass Sie anderen Fahrzeugen Vorfahrt lassen müssen.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q009",
            categoryID: "signs",
            text: "Was bedeutet ein blaues Schild mit weißem Pfeil nach rechts?",
            options: ["Rechts abbiegen", "Vorgeschriebene Fahrtrichtung rechts", "Einbahnstraße rechts"],
            correctAnswer: "Vorgeschriebene Fahrtrichtung rechts",
            explanation: "Ein blaues Schild mit weißem Pfeil nach rechts schreibt die Fahrtrichtung rechts vor.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q010",
            categoryID: "rules",
            text: "Wie viel Promille Blutalkohol sind beim Führen eines Fahrzeugs erlaubt?",
            options: ["0,5 Promille", "0,8 Promille", "0,0 Promille"],
            correctAnswer: "0,5 Promille",
            explanation: "In Deutschland gilt eine Promillegrenze von 0,5 für Fahranfänger und Fahrer unter 21 Jahren gilt 0,0 Promille.",
            imageURL: nil,
            difficulty: .medium
        ),
        QuizQuestion(
            id: "q011",
            categoryID: "rules",
            text: "Welche Höchstgeschwindigkeit gilt innerorts?",
            options: ["30 km/h", "50 km/h", "70 km/h"],
            correctAnswer: "50 km/h",
            explanation: "Innerorts gilt eine Höchstgeschwindigkeit von 50 km/h, sofern keine anderen Schilder aufgestellt sind.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q012",
            categoryID: "rules",
            text: "Welche Höchstgeschwindigkeit gilt auf der Autobahn für PKW?",
            options: ["100 km/h", "130 km/h (Richtgeschwindigkeit)", "150 km/h"],
            correctAnswer: "130 km/h (Richtgeschwindigkeit)",
            explanation: "Auf deutschen Autobahnen gilt eine Richtgeschwindigkeit von 130 km/h, sofern kein Tempolimit ausgeschildert ist.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q013",
            categoryID: "rules",
            text: "Was müssen Sie tun, wenn Sie einen Unfall verursacht haben?",
            options: ["Weiterfahren", "Anhalten und Hilfe leisten", "Polizei anrufen und weiterfahren"],
            correctAnswer: "Anhalten und Hilfe leisten",
            explanation: "Bei einem Unfall müssen Sie anhalten, Hilfe leisten und die Polizei verständigen.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q014",
            categoryID: "rules",
            text: "Wann müssen Sie Ihr Fahrzeug beleuchten?",
            options: ["Nur nachts", "Bei schlechter Sicht und nachts", "Immer"],
            correctAnswer: "Bei schlechter Sicht und nachts",
            explanation: "Das Fahrzeug muss bei Dunkelheit und schlechter Sicht beleuchtet werden.",
            imageURL: nil,
            difficulty: .easy
        ),
        QuizQuestion(
            id: "q015",
            categoryID: "rules",
            text: "Wie groß muss der Sicherheitsabstand bei 100 km/h mindestens sein?",
            options: ["50 Meter", "100 Meter", "30 Meter"],
            correctAnswer: "50 Meter",
            explanation: "Bei 100 km/h sollte der Sicherheitsabstand mindestens 50 Meter (halber Tacho) betragen.",
            imageURL: nil,
            difficulty: .medium
        )
    ]
}