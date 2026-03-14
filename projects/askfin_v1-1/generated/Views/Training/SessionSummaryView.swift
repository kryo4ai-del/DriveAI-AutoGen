import SwiftUI

struct SessionSummaryView: View {

    let session: TrainingSession
    let competenceService: TopicCompetenceService
    let overallReadinessScore: Double
    let onTrainWeaknesses: () -> Void
    let onTrainCoverage: () -> Void
    let onStartExamSim: () -> Void
