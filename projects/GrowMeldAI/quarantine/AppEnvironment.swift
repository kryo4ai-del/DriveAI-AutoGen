// Models/AppEnvironment.swift

import SwiftUI
import Combine
import Foundation

// MARK: - Supporting Service Types

final class TrialLocalDataSource {
    init() {}
}

final class QuotaManager {
    init(dataSource: TrialLocalDataSource) {}
}

final class TrialService {
    init(dataSource: TrialLocalDataSource, quotaManager: QuotaManager, analytics: AnalyticsService) {}
}

final class LocalDataService {
    init() {}
}

final class AnalyticsService {
    init() {}
    
    func track(_ event: String, properties: [String: Any]? = nil) {
        #if DEBUG
        print("[Analytics] Event: \(event), properties: \(properties ?? [:])")
        #endif
    }
}

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