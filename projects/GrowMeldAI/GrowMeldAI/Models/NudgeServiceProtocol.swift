// Services/NudgeService.swift
protocol NudgeServiceProtocol {
    func determineNudge() async throws -> DailyNudge?
    func recordNudgeEngagement(_ nudge: DailyNudge, accepted: Bool) async throws
}

struct DailyNudge {
    let id: UUID
    let headline: String          // "Noch 4 Fragen bis zur 80%-Schwelle"
    let subheading: String        // Psychology-driven CTA
    let category: String?         // Optional category focus
    let suggestedQuestionCount: Int
    let urgency: UrgencyLevel     // .immediate, .soon, .eventual
    
    enum UrgencyLevel {
        case immediate      // Low confidence + overdue
        case soon           // Due soon
        case eventual       // Maintenance
    }
}

final class NudgeService: NudgeServiceProtocol {
    func determineNudge() async throws -> DailyNudge? {
        let scheduler = SpacedRepetitionScheduler()
        let overdue = try await scheduler.getNextReviewQueue(limit: 1)
        
        guard let question = overdue.first else { return nil }
        
        let confidence = try await memoryService.getConfidence(for: question)
        let category = try await dataService.getCategory(for: question)
        
        let urgency: DailyNudge.UrgencyLevel
        if confidence < 0.5 && Calendar.current.dateComponents([.day], from: question.lastReviewDate, to: Date()).day ?? 0 > 1 {
            urgency = .immediate
        } else if Date() > question.nextReviewDate {
            urgency = .soon
        } else {
            urgency = .eventual
        }
        
        return DailyNudge(
            id: UUID(),
            headline: "Noch 4 Fragen bis zur 80%-Schwelle",
            subheading: "Festigen Sie Ihr Wissen mit 5 Wiederholungsfragen",
            category: category.name,
            suggestedQuestionCount: 5,
            urgency: urgency
        )
    }
}