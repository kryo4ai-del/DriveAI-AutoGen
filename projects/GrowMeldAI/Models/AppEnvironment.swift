import Foundation
import SwiftUI
import Combine

// MARK: - AppEnvironment

final class AppEnvironment: ObservableObject {
    let trialService: TrialService
    let quotaManager: QuotaManager
    let localDataService: LocalDataService
    let analyticsService: AnalyticsService

    init() {
        self.analyticsService = AnalyticsService()
        self.quotaManager = QuotaManager()
        self.trialService = TrialService()
        self.localDataService = LocalDataService()
    }
}