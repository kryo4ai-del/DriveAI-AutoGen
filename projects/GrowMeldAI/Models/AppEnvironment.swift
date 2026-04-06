import Foundation
import SwiftUI
import Combine

// MARK: - AppEnvironment

final class AppEnvironment: ObservableObject {
    let trialService: TrialService
    let quotaManager: GrowMeldAI.QuotaManager
    let localDataService: GrowMeldAI.LocalDataService
    let analyticsService: GrowMeldAI.AnalyticsService

    @MainActor
    init() {
        let analytics = GrowMeldAI.AnalyticsService()
        let quota = GrowMeldAI.QuotaManager()
        let trial = TrialService()
        let local = GrowMeldAI.LocalDataService()

        self.analyticsService = analytics
        self.quotaManager = quota
        self.trialService = trial
        self.localDataService = local
    }
}