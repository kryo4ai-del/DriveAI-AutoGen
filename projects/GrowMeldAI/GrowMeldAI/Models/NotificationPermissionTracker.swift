// Services/Notifications/NotificationPermissionTracker.swift
import Foundation

@MainActor
final class NotificationPermissionTracker {
    enum PermissionState: Codable {
        case never
        case accepted(date: Date)
        case denied(date: Date, nextRetryDate: Date?)
    }
    
    private let userDefaults: UserDefaults
    private let keyPrefix = "notification_permission_"
    private let queue = DispatchQueue(
        label: "com.driveai.notification.tracker",
        attributes: .concurrent
    )
    private var stateCache: [String: PermissionState] = [:]
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Public API
    
    func canRequest(for trigger: NotificationTrigger) -> Bool {
        queue.sync {
            let state = loadState(for: trigger)
            
            switch state {
            case .accepted:
                return false
            case .denied(_, let retryDate):
                return retryDate.map { Date() >= $0 } ?? false
            case .never:
                return true
            }
        }
    }
    
    func recordAcceptance(trigger: NotificationTrigger) {
        queue.async(flags: .barrier) { [weak self] in
            let state = PermissionState.accepted(date: Date())
            self?.saveState(state, for: trigger)
            self?.stateCache[trigger.rawValue] = state
        }
    }
    
    func recordDismissal(trigger: NotificationTrigger, retryAfterDays: Int = 7) {
        queue.async(flags: .barrier) { [weak self] in
            let nextRetryDate = Calendar.current.date(byAdding: .day, value: retryAfterDays, to: Date())
            let state = PermissionState.denied(date: Date(), nextRetryDate: nextRetryDate)
            self?.saveState(state, for: trigger)
            self?.stateCache[trigger.rawValue] = state
        }
    }
    
    func getState(for trigger: NotificationTrigger) -> PermissionState {
        queue.sync {
            loadState(for: trigger)
        }
    }
    
    // MARK: - Private Helpers
    
    private func loadState(for trigger: NotificationTrigger) -> PermissionState {
        let key = keyPrefix + trigger.rawValue
        
        // Check cache first (read-only, safe in sync block)
        if let cached = stateCache[trigger.rawValue] {
            return cached
        }
        
        guard let data = userDefaults.data(forKey: key) else {
            return .never
        }
        
        let decoder = JSONDecoder()
        let state = (try? decoder.decode(PermissionState.self, from: data)) ?? .never
        
        return state
    }
    
    private func saveState(_ state: PermissionState, for trigger: NotificationTrigger) {
        let key = keyPrefix + trigger.rawValue
        let encoder = JSONEncoder()
        
        if let data = try? encoder.encode(state) {
            userDefaults.set(data, forKey: key)
            stateCache[trigger.rawValue] = state
        }
    }
}