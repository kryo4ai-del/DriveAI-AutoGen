import Foundation
import SwiftUI
import Combine

// MARK: - AppEnvironment

final class AppEnvironment: ObservableObject {
    let trialService: TrialService
    let quotaManager: GrowMeldAI.QuotaManager
    let localDataService: GrowMeldAI.LocalDataService
    let analyticsService: GrowMeldAI.AnalyticsService

    init() {
        self.analyticsService = GrowMeldAI.AnalyticsService()
        self.quotaManager = GrowMeldAI.QuotaManager()
        self.trialService = TrialService()
        self.localDataService = GrowMeldAI.LocalDataService()
    }
}