import Foundation

final class QuestionCategoryDetectionService {

    private typealias KeywordEntry = (keyword: String, category: QuestionCategory)

    private let keywords: [KeywordEntry] = [
        // Right of Way
        ("vorfahrt",             .rightOfWay), ("vorrang",              .rightOfWay),
        ("rechts vor links",     .rightOfWay), ("kreuzung",             .rightOfWay),
        ("einmündung",           .rightOfWay), ("bevorrechtig",         .rightOfWay),

        // Traffic Signs
        ("verkehrszeichen",      .trafficSigns), ("zeichen",            .trafficSigns),
        ("schild",               .trafficSigns), ("markierung",         .trafficSigns),
        ("fahrbahnmarkierung",   .trafficSigns),

        // Speed
        ("geschwindigkeit",      .speed), ("km/h",                     .speed),
        ("tempo",                .speed), ("höchstgeschwindigkeit",     .speed),
        ("schnell",              .speed), ("langsam",                   .speed),
        ("schrittgeschwindigkeit", .speed),

        // Parking
        ("parken",               .parking), ("haltestelle",            .parking),
        ("parkplatz",            .parking), ("einparken",              .parking),
        ("parkverbot",           .parking), ("halteverbot",            .parking),

        // Turning
        ("abbiegen",             .turning), ("wenden",                 .turning),
        ("kehrtwendung",         .turning), ("abbiegepfeil",           .turning),
        ("umkehren",             .turning),

        // Overtaking
        ("überholen",            .overtaking), ("vorbeifahren",        .overtaking),
        ("überholverbot",        .overtaking), ("überholvorgang",      .overtaking),

        // Distance
        ("abstand",              .distance), ("sicherheitsabstand",    .distance),
        ("mindestabstand",       .distance), ("reaktionsweg",          .distance),
        ("bremsweg",             .distance),

        // Alcohol & Drugs
        ("alkohol",              .alcoholDrugs), ("promille",           .alcoholDrugs),
        ("drogen",               .alcoholDrugs), ("medikamente",        .alcoholDrugs),
        ("rauschmittel",         .alcoholDrugs), ("berauscht",          .alcoholDrugs),
        ("fahruntüchtig",        .alcoholDrugs), ("beeinflussung",      .alcoholDrugs),

        // Safety
        ("sicherheitsgurt",      .safety), ("gurt",                    .safety),
        ("helm",                 .safety), ("kindersitz",              .safety),
        ("schutzausrüstung",     .safety), ("airbag",                  .safety),
        ("warndreieck",          .safety), ("pannensicherung",         .safety),

        // Vehicle Technology
        ("hauptuntersuchung",    .vehicleTechnology), ("tüv",          .vehicleTechnology),
        ("bremssystem",          .vehicleTechnology), ("reifendruck",   .vehicleTechnology),
        ("scheinwerfer",         .vehicleTechnology), ("motor",         .vehicleTechnology),
        ("bremsen",              .vehicleTechnology), ("reifen",        .vehicleTechnology),

        // Environment
        ("umwelt",               .environment), ("emission",           .environment),
        ("abgas",                .environment), ("kraftstoff",         .environment),
        ("energieverbrauch",     .environment), ("lärm",               .environment),
        ("umweltzone",           .environment), ("schadstoff",         .environment),
    ]

    func detectCategory(questionText: String, answers: [String]) -> CategoryDetectionResult {
        let combined = ([questionText] + answers).joined(separator: " ").lowercased()

        var scores: [QuestionCategory: Int] = [:]
        var matched: [QuestionCategory: [String]] = [:]

        for entry in keywords where combined.contains(entry.keyword) {
            scores[entry.category, default: 0] += 1
            matched[entry.category, default: []].append(entry.keyword)
        }

        guard let top = scores.max(by: { $0.value < $1.value }) else {
            return CategoryDetectionResult(category: .general, confidence: 0, matchedKeywords: [])
        }

        let totalMatches = scores.values.reduce(0, +)
        let confidence = totalMatches > 0 ? Double(top.value) / Double(totalMatches) : 0

        return CategoryDetectionResult(
            category: top.key,
            confidence: confidence,
            matchedKeywords: matched[top.key] ?? []
        )
    }
}
