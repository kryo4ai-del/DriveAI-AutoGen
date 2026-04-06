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
        let dataSource = TrialLocalDataSource()
        let analytics = AnalyticsService()
        let quota = QuotaManager(dataSource: dataSource)
        let trial = TrialService(
            dataSource: dataSource,
            quotaManager: quota,
            analytics: analytics
        )
        let local = LocalDataService()

        self.analyticsService = analytics
        self.quotaManager = quota
        self.trialService = trial
        self.localDataService = local
    }
}