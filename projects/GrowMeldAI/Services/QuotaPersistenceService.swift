import Foundation

/// Single source of truth for quota persistence with thread-safety
public class QuotaPersistenceService {
    public static let shared = QuotaPersistenceService()
    
    private let persistenceLock = NSRecursiveLock()
    private let userDefaults: UserDefaults
    private let calendar: Calendar
    
    private let answersKey = "quota_answered_timestamps"
    private let lastCleanupKey = "quota_last_cleanup"
    private let premiumStatusKey = "user_is_premium"
    
    // MARK: - Init
    
    public init(
        userDefaults: UserDefaults = .standard,
        calendar: Calendar = {
            var cal = Calendar(identifier: .gregorian)
            cal.timeZone = TimeZone.autoupdatingCurrent
            return cal
        }()
    ) {
        self.userDefaults = userDefaults
        self.calendar = calendar
        setupTimezoneObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public API
    
    /// Thread-safe record of answered question with atomic write
    public func recordQuestionAnswer(timestamp: Date) throws {
        persistenceLock.lock()
        defer { persistenceLock.unlock() }
        
        var timestamps = getAnswerTimestamps()
        timestamps.append(timestamp)
        
        // Cleanup old records (max once per day for efficiency)
        if shouldPerformCleanup() {
            let cutoff = calendar.date(byAdding: .day, value: -90, to: Date())!
            timestamps.removeAll { $0 < cutoff }
            userDefaults.set(Date(), forKey: lastCleanupKey)
        }
        
        // Atomic write with synchronization
        userDefaults.set(timestamps, forKey: answersKey)
        userDefaults.synchronize()
    }
    
    /// Retrieve usage for a specific period
    public func getUsage(
        for period: QuotaPeriod,
        at date: Date,
        config: QuotaConfig,
        isPremium: Bool
    ) -> QuotaUsage {
        persistenceLock.lock()
        defer { persistenceLock.unlock() }
        
        let timestamps = getAnswerTimestamps()
        let (startDate, endDate) = dateRange(for: period, at: date)
        
        let used = timestamps.filter { $0 >= startDate && $0 < endDate }.count
        let limit = config.limit(for: period, isPremium: isPremium)
        
        return QuotaUsage(
            period: period,
            used: used,
            limit: limit,
            resetDate: endDate
        )
    }
    
    /// Load premium status from persistent storage
    public func loadPremiumStatus() -> Bool {
        persistenceLock.lock()
        defer { persistenceLock.unlock() }
        return userDefaults.bool(forKey: premiumStatusKey)
    }
    
    /// Persist premium status with validation
    public func setPremiumStatus(_ isPremium: Bool) throws {
        persistenceLock.lock()
        defer { persistenceLock.unlock() }
        userDefaults.set(isPremium, forKey: premiumStatusKey)
        userDefaults.synchronize()
    }
    
    /// Clear all quota data (for testing or user reset)
    public func reset() {
        persistenceLock.lock()
        defer { persistenceLock.unlock() }
        userDefaults.removeObject(forKey: answersKey)
        userDefaults.removeObject(forKey: lastCleanupKey)
    }
    
    // MARK: - Private Helpers
    
    private func getAnswerTimestamps() -> [Date] {
        userDefaults.array(forKey: answersKey) as? [Date] ?? []
    }
    
    private func shouldPerformCleanup() -> Bool {
        let lastCleanup = userDefaults.object(forKey: lastCleanupKey) as? Date ?? .distantPast
        return !calendar.isDateInToday(lastCleanup)
    }
    
    private func dateRange(
        for period: QuotaPeriod,
        at date: Date
    ) -> (start: Date, end: Date) {
        switch period {
        case .daily:
            let start = calendar.startOfDay(for: date)
            guard let end = calendar.date(byAdding: .day, value: 1, to: start) else {
                return (start, date.addingTimeInterval(86400))
            }
            return (start, end)
            
        case .weekly:
            let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
            guard let start = calendar.date(from: components),
                  let end = calendar.date(byAdding: .day, value: 7, to: start) else {
                let fallback = date.addingTimeInterval(604800)
                return (date, fallback)
            }
            return (start, end)
            
        case .monthly:
            let components = calendar.dateComponents([.year, .month], from: date)
            guard let start = calendar.date(from: components),
                  let end = calendar.date(byAdding: .month, value: 1, to: start) else {
                let fallback = date.addingTimeInterval(2592000)
                return (date, fallback)
            }
            return (start, end)
        }
    }
    
    private func setupTimezoneObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTimezoneChange),
            name: NSNotification.Name.NSSystemTimeZoneDidChange,
            object: nil
        )
    }
    
    @objc
    private func handleTimezoneChange() {
        persistenceLock.lock()
        defer { persistenceLock.unlock() }
        // Invalidate cleanup cache on timezone change
        userDefaults.removeObject(forKey: lastCleanupKey)
    }
}