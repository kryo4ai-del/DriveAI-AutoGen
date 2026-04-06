protocol ScheduleReviewsUseCase {
    func execute(for gap: LearningGap) async throws -> [ScheduledReview]
}

class ScheduleReviewsUseCaseImpl: ScheduleReviewsUseCase {
    func execute(for gap: LearningGap) async throws -> [ScheduledReview] {
        let baseDate = Date()
        
        let schedule: [(day: Int, description: String, count: Int)] = {
            switch gap.gapSeverity {
            case .critical:
                return [
                    (1, "1. Wiederholung – erste Verfestigung", 1),
                    (3, "2. Wiederholung – Konsolidierung", 2),
                    (7, "3. Wiederholung – Langzeitgedächtnis", 2)
                ]
            case .moderate:
                return [
                    (2, "1. Wiederholung – erste Verfestigung", 1),
                    (5, "2. Wiederholung – Konsolidierung", 2),
                    (14, "3. Wiederholung – Langzeitgedächtnis", 1)
                ]
            case .minor:
                return [
                    (3, "Kontrolle – halten Sie das Wissen", 1)
                ]
            }
        }()
        
        return schedule.map { day, desc, count in
            ScheduledReview(
                id: UUID(),
                day: day,
                description: desc,
                practiceCount: count,
                dueDate: Calendar.current.date(byAdding: .day, value: day, to: baseDate)!
            )
        }
    }
}