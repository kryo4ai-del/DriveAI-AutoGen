// MARK: - Services/Analytics/AnalyticsBackgroundTask.swift

import Foundation
import BackgroundTasks
import os

class AnalyticsBackgroundTask {
    nonisolated static let identifier = "com.driveai.analytics.flush"
    nonisolated private static let logger = Logger(subsystem: "com.driveai.analytics", category: "background")
    
    static func register() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: identifier,
            using: nil
        ) { task in
            handleBackgroundFetch(task as! BGProcessingTask)
        }
    }
    
    static func schedule() {
        let request = BGProcessingTaskRequest(identifier: identifier)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
            logger.info("Analytics background task scheduled")
        } catch {
            logger.error("Failed to schedule analytics task: \(error.localizedDescription)")
        }
    }
    
    private static func handleBackgroundFetch(_ task: BGProcessingTask) {
        // Prevent task from being terminated too early
        let queue = AnalyticsEventQueue()
        
        Task {
            defer { task.setTaskComplete(success: true) }
            
            let result = await queue.flushPending { event in
                Firebase.Analytics.logEvent(event.eventName, parameters: event.parameters)
            }
            
            logger.info("Background flush: \(result.flushed) events sent")
            
            // Reschedule for next opportunity
            schedule()
        }
        
        task.expirationHandler = {
            logger.warning("Analytics background task expired")
            AnalyticsBackgroundTask.schedule()
        }
    }
}