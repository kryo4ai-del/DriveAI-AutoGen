import Foundation

// MARK: - Topic Area (16 driving theory domains)
enum TopicArea: String, CaseIterable, Identifiable {
    case rightOfWay, trafficSigns, speed, distance, overtaking, parking
    case turning, highway, railwayCrossing, visibility, alcoholDrugs
    case vehicleTech, environment, passengers, emergency, general
    
    var id: String { rawValue }
    
    var localizedName: String {
        switch self {
        case .rightOfWay: return "Vorfahrt & Vorrang"
        case .trafficSigns: return "Verkehrszeichen"
        case .speed: return "Geschwindigkeit"
        case .distance: return "Abstände"
        case .overtaking: return "Überholen"
        case .parking: return "Parken"
        case .turning: return "Abbiegen"
        case .highway: return "Autobahn"
        case .railwayCrossing: return "Bahnübergänge"
        case .visibility: return "Sichtbarkeit"
        case .alcoholDrugs: return "Alkohol & Drogen"
        case .vehicleTech: return "Fahrzeugtechnik"
        case .environment: return "Umwelt"
        case .passengers: return "Fahrgäste"
        case .emergency: return "Notfälle"
        case .general: return "Allgemein"
        }
    }
}

// MARK: - Competence Level
enum CompetenceLevel: Int, Codable, Comparable {
    case notStarted = 0
    case weak = 1
    case shaky = 2
    case solid = 3
    case mastered = 4
    
    var color: Color {
        switch self {
        case .notStarted: return .gray
        case .weak: return .red
        case .shaky: return .orange
        case .solid: return .yellow
        case .mastered: return Color(red: 0.2, green: 0.8, blue: 0.2) // green
        }
    }
    
    var label: String {
        switch self {
        case .notStarted: return "Nicht gestartet"
        case .weak: return "Schwach"
        case .shaky: return "Unsicher"
        case .solid: return "Solide"
        case .mastered: return "Beherrscht"
        }
    }
    
    static func < (lhs: CompetenceLevel, rhs: CompetenceLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Topic Competence (per-topic accuracy with weighting)
struct TopicCompetence: Identifiable, Codable {
    let id: String
    let topic: TopicArea
    var totalAnswers: Int = 0
    var correctAnswers: Int = 0
    var lastReviewedDate: Date?
    
    // Recency weighting: recent answers count more
    var weightedAccuracy: Double {
        guard totalAnswers > 0 else { return 0 }
        
        let baseAccuracy = Double(correctAnswers) / Double(totalAnswers)
        
        // Apply recency decay: questions older than 7 days count less
        if let lastDate = lastReviewedDate {
            let daysSinceReview = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
            let recencyFactor = min(1.0, max(0.5, 1.0 - Double(daysSinceReview) / 30.0))
            return baseAccuracy * recencyFactor
        }
        
        return baseAccuracy
    }
    
    var competenceLevel: CompetenceLevel {
        switch weightedAccuracy {
        case 0..<0.4: return .weak
        case 0.4..<0.65: return .shaky
        case 0.65..<0.85: return .solid
        case 0.85...: return .mastered
        default: return .notStarted
        }
    }
}

// MARK: - Spacing Item (spaced repetition queue)
struct SpacingItem: Identifiable, Codable {
    let id: String
    let topic: TopicArea
    var consecutiveCorrect: Int = 0
    var nextReviewDate: Date
    var reviewCount: Int = 0
    
    /// Interval thresholds: wrong → 1 day, then 3, 7, 14, 30
    static func nextInterval(after correctCount: Int) -> Int {
        switch correctCount {
        case 0: return 1    // 1 day after wrong answer
        case 1: return 3    // 3 days after 1 correct
        case 2: return 7    // 7 days
        case 3: return 14   // 14 days
        default: return 30  // 30 days (mastered)
        }
    }
}

// MARK: - Training Session
struct TrainingSession: Identifiable, Codable {
    let id: String
    let type: SessionType
    let startedAt: Date
    var endedAt: Date?
    let questionIds: [String]
    var userAnswers: [Int] = [] // indices of selected options
    
    enum SessionType: String, Codable {
        case dailyChallenge = "daily_challenge"
        case topicFocus = "topic_focus"
        case weakAreaReview = "weak_review"
        case fullSimulation = "full_sim"
    }
}

// MARK: - Session Question (question + metadata for training)
struct SessionQuestion: Identifiable, Codable {
    let id: String
    let text: String
    let options: [String] // [A, B, C, D]
    let correctIndex: Int
    let topic: TopicArea
    let questionType: QuestionType
    let explanation: String // 1-2 sentences, why this answer
    let image: String? // path to image if applicable
    
    enum QuestionType: String, Codable {
        case recall = "Abfrage"           // "Recall: Verkehrszeichen"
        case application = "Anwendung"     // "Anwendung: Gefahrensituation"
        case scenario = "Szenario"
    }
    
    var typeLabel: String {
        "\(questionType.rawValue): \(topic.localizedName)"
    }
}