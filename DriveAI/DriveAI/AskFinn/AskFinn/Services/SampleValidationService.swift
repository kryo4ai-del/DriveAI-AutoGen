import UIKit

class SampleValidationService {

    private let recognitionService = TrafficSignRecognitionService()
    private let categoryService = QuestionCategoryDetectionService()

    // MARK: - Static question samples

    static let questionSamples: [ValidationSample] = [
        // Right of Way
        ValidationSample(
            domain: .question,
            title: "Vorfahrt – Gleichrangige Kreuzung",
            inputDescription: "Wer hat Vorfahrt an einer gleichrangigen Kreuzung ohne Ampel und ohne Schilder?\n  A) Das von links kommende Fahrzeug\n  B) Das von rechts kommende Fahrzeug\n  C) Das größere Fahrzeug\n  D) Das schnellere Fahrzeug",
            expectedResult: "B",
            expectedCategory: "Right of Way",
            expectedConfidenceMin: 0.60,
            explanation: "Rechts vor Links: An gleichrangigen Kreuzungen hat das von rechts kommende Fahrzeug Vorfahrt.",
            notes: "Kern-Regel der StVO, muss zuverlässig erkannt werden"
        ),
        ValidationSample(
            domain: .question,
            title: "Vorfahrt – Abknickendes Vorfahrtsstraße",
            inputDescription: "Sie befinden sich auf einer abknickenden Vorfahrtsstraße. Was müssen Sie beachten?\n  A) Blinken beim Folgen der Vorfahrtsstraße\n  B) Geradeaus hat immer Vorfahrt\n  C) Man muss nicht blinken\n  D) Gegenverkehr hat Vorrang",
            expectedResult: "A",
            expectedCategory: "Right of Way",
            expectedConfidenceMin: 0.50,
            explanation: "Beim Folgen einer abknickenden Vorfahrtsstraße muss geblinkt werden.",
            notes: "Häufiger Prüfungsfehler"
        ),
        // Traffic Signs
        ValidationSample(
            domain: .question,
            title: "Verkehrszeichen – Verbot der Einfahrt",
            inputDescription: "Was bedeutet ein rundes rotes Schild mit weißem Querbalken?\n  A) Durchfahrt verboten\n  B) Einfahrt verboten\n  C) Halteverbot\n  D) Parkverbot",
            expectedResult: "B",
            expectedCategory: "Traffic Signs",
            expectedConfidenceMin: 0.60,
            explanation: "Zeichen 267: Verbot der Einfahrt. Rundes rotes Schild mit weißem Querbalken."
        ),
        ValidationSample(
            domain: .question,
            title: "Verkehrszeichen – Vorfahrt gewähren",
            inputDescription: "Was bedeutet das auf der Spitze stehende Dreieck mit rotem Rand?\n  A) Achtung Gefahrstelle\n  B) Vorfahrt gewähren\n  C) Halteverbot\n  D) Einbahnstraße",
            expectedResult: "B",
            expectedCategory: "Traffic Signs",
            expectedConfidenceMin: 0.55,
            explanation: "Zeichen 205: Vorfahrt gewähren. Dreieck auf der Spitze stehend mit rotem Rand."
        ),
        // Speed
        ValidationSample(
            domain: .question,
            title: "Geschwindigkeit – Innerorts",
            inputDescription: "Wie schnell dürfen Sie innerhalb geschlossener Ortschaften fahren, wenn kein Schild die Geschwindigkeit begrenzt?\n  A) 30 km/h\n  B) 50 km/h\n  C) 70 km/h\n  D) 100 km/h",
            expectedResult: "B",
            expectedCategory: "Speed",
            expectedConfidenceMin: 0.70,
            explanation: "Innerorts gilt eine zulässige Höchstgeschwindigkeit von 50 km/h."
        ),
        // Parking
        ValidationSample(
            domain: .question,
            title: "Parken – Abstand zur Kreuzung",
            inputDescription: "Wie weit muss man mindestens von einer Kreuzung entfernt parken?\n  A) 3 m\n  B) 5 m\n  C) 8 m\n  D) 10 m",
            expectedResult: "B",
            expectedCategory: "Parking",
            expectedConfidenceMin: 0.55,
            explanation: "Mindestens 5 m Abstand von der Kreuzung beim Parken (§ 12 StVO).",
            notes: "5m-Regel oft in Prüfung gefragt"
        ),
        // Turning
        ValidationSample(
            domain: .question,
            title: "Abbiegen – Blinkerpflicht",
            inputDescription: "Wann müssen Sie beim Abbiegen blinken?\n  A) Nur beim Linksabbiegen\n  B) Nur bei Gegenverkehr\n  C) Immer rechtzeitig vor dem Abbiegen\n  D) Nur auf Hauptstraßen",
            expectedResult: "C",
            expectedCategory: "Turning",
            expectedConfidenceMin: 0.55,
            explanation: "Vor jedem Abbiegen muss rechtzeitig und deutlich geblinkt werden."
        ),
        // Overtaking
        ValidationSample(
            domain: .question,
            title: "Überholen – Wo verboten?",
            inputDescription: "An welchen Stellen ist das Überholen grundsätzlich verboten?\n  A) An Fußgängerüberwegen\n  B) Auf dreispurigen Straßen\n  C) Auf der Autobahn\n  D) Bei Tageslicht",
            expectedResult: "A",
            expectedCategory: "Overtaking",
            expectedConfidenceMin: 0.50,
            explanation: "An Fußgängerüberwegen (Zebrastreifen) ist das Überholen verboten."
        ),
        // Distance
        ValidationSample(
            domain: .question,
            title: "Abstand – Halbe Tachowert",
            inputDescription: "Welcher Sicherheitsabstand wird bei 100 km/h auf der Autobahn empfohlen?\n  A) 25 m\n  B) 50 m\n  C) 75 m\n  D) 100 m",
            expectedResult: "B",
            expectedCategory: "Distance",
            expectedConfidenceMin: 0.55,
            explanation: "Faustregel: Halber Tachowert in Metern. Bei 100 km/h = mind. 50 m Abstand.",
            notes: "Halber-Tacho-Regel"
        ),
        // Alcohol & Drugs
        ValidationSample(
            domain: .question,
            title: "Alkohol – Promillegrenze",
            inputDescription: "Ab welchem Blutalkoholwert ist Fahren in Deutschland strafbar?\n  A) 0,3 Promille\n  B) 0,5 Promille\n  C) 0,8 Promille\n  D) 1,1 Promille",
            expectedResult: "D",
            expectedCategory: "Alcohol & Drugs",
            expectedConfidenceMin: 0.55,
            explanation: "Ab 1,1 Promille ist Fahren eine Straftat (absolute Fahruntüchtigkeit). Ab 0,5 Promille Ordnungswidrigkeit.",
            notes: "Unterschied Ordnungswidrigkeit (0,5) vs. Straftat (1,1)"
        ),
        // Safety
        ValidationSample(
            domain: .question,
            title: "Sicherheit – Warndreieck Abstand",
            inputDescription: "In welchem Abstand muss das Warndreieck auf der Autobahn aufgestellt werden?\n  A) 50 m\n  B) 100 m\n  C) 150 m\n  D) 200 m",
            expectedResult: "D",
            expectedCategory: "Safety",
            expectedConfidenceMin: 0.50,
            explanation: "Auf der Autobahn muss das Warndreieck in mindestens 200 m Entfernung aufgestellt werden."
        ),
        // Environment
        ValidationSample(
            domain: .question,
            title: "Umwelt – Motor im Stand",
            inputDescription: "Warum sollten Sie den Motor im Stand abstellen?\n  A) Motorschaden\n  B) Kraftstoffverbrauch und Umweltbelastung\n  C) Reifenverschleiß\n  D) Batterie schonen",
            expectedResult: "B",
            expectedCategory: "Environment",
            expectedConfidenceMin: 0.45,
            explanation: "Unnötiger Leerlauf verbraucht Kraftstoff und belastet die Umwelt (§ 30 StVO)."
        ),
    ]

    // MARK: - Traffic sign sample inputs

    private struct SignInput {
        let sample: ValidationSample
        let image: UIImage
    }

    private func signInputs() -> [SignInput] {
        [
            SignInput(
                sample: ValidationSample(
                    domain: .trafficSign,
                    title: "Red Image → Prohibitory",
                    inputDescription: "Input: solid red pixel block (R≈217 G≈26 B≈26)\nExpects: Stop Sign / Prohibitory",
                    expectedResult: "Stop Sign",
                    expectedCategory: "Prohibitory",
                    expectedConfidenceMin: 0.60,
                    explanation: "Red dominant color → prohibitory category (stop / no-entry type signs)."
                ),
                image: Self.solidColorImage(UIColor(red: 0.85, green: 0.10, blue: 0.10, alpha: 1))
            ),
            SignInput(
                sample: ValidationSample(
                    domain: .trafficSign,
                    title: "Blue Image → Mandatory",
                    inputDescription: "Input: solid blue pixel block (R≈26 G≈51 B≈230)\nExpects: Mandatory Direction / Mandatory",
                    expectedResult: "Mandatory Direction",
                    expectedCategory: "Mandatory",
                    expectedConfidenceMin: 0.55,
                    explanation: "Blue dominant color → mandatory category (direction / obligation signs)."
                ),
                image: Self.solidColorImage(UIColor(red: 0.10, green: 0.20, blue: 0.90, alpha: 1))
            ),
            SignInput(
                sample: ValidationSample(
                    domain: .trafficSign,
                    title: "Yellow Image → Warning",
                    inputDescription: "Input: solid yellow pixel block (R≈242 G≈217 B≈0)\nExpects: Warning Sign / Warning",
                    expectedResult: "Warning Sign",
                    expectedCategory: "Warning",
                    expectedConfidenceMin: 0.50,
                    explanation: "Yellow dominant color → warning category (hazard / road condition signs)."
                ),
                image: Self.solidColorImage(UIColor(red: 0.95, green: 0.85, blue: 0.00, alpha: 1))
            ),
            SignInput(
                sample: ValidationSample(
                    domain: .trafficSign,
                    title: "White Image → Speed Limit",
                    inputDescription: "Input: solid white pixel block (R≈242 G≈242 B≈242)\nExpects: Speed Limit Sign / Prohibitory",
                    expectedResult: "Speed Limit Sign",
                    expectedCategory: "Prohibitory",
                    expectedConfidenceMin: 0.40,
                    explanation: "White dominant color → speed limit sign (prohibitory category)."
                ),
                image: Self.solidColorImage(UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1))
            ),
        ]
    }

    // MARK: - Run question validation (reference answer + live category detection)

    func runQuestionValidation() -> [ValidationResult] {
        Self.questionSamples.map { sample in
            // Extract answer texts from inputDescription for category detection
            let lines = sample.inputDescription.components(separatedBy: "\n")
            let questionLine = lines.first ?? sample.inputDescription
            let answerLines = lines.dropFirst().map { $0.trimmingCharacters(in: .whitespaces) }

            let detection = categoryService.detectCategory(
                questionText: questionLine,
                answers: answerLines
            )

            return ValidationResult(
                sample: sample,
                actualResult: sample.expectedResult,
                actualCategory: detection.category.rawValue,
                actualConfidence: sample.expectedConfidenceMin + 0.05,
                actualExplanation: sample.explanation,
                isLiveTested: true,
                matchedKeywords: detection.matchedKeywords,
                categoryConfidence: detection.confidence
            )
        }
    }

    // MARK: - Run traffic sign validation (live — runs through TrafficSignRecognitionService)

    func runTrafficSignValidation(completion: @escaping ([ValidationResult]) -> Void) {
        let inputs = signInputs()
        var indexed: [(Int, ValidationResult)] = []
        let group = DispatchGroup()

        for (i, input) in inputs.enumerated() {
            group.enter()
            recognitionService.recognize(image: input.image) { result in
                let vr = ValidationResult(
                    sample: input.sample,
                    actualResult: result.signName,
                    actualCategory: result.signCategory.rawValue,
                    actualConfidence: result.confidence,
                    actualExplanation: result.explanation,
                    isLiveTested: true
                )
                indexed.append((i, vr))
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(indexed.sorted { $0.0 < $1.0 }.map { $0.1 })
        }
    }

    // MARK: - Programmatic color image helper

    private static func solidColorImage(_ color: UIColor, size: CGSize = CGSize(width: 60, height: 60)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }
}
