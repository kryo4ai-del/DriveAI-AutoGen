@MainActor
final class UserPreferences {
    static let shared = UserPreferences()
    
    var examDate: Date? {
        get {
            defaults.object(forKey: Key.examDate.rawValue) as? Date
        }
        set {
            guard let newDate = newValue else {
                defaults.removeObject(forKey: Key.examDate.rawValue)
                return
            }
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let examDay = calendar.startOfDay(for: newDate)
            
            // Validation: exam date must be in future
            guard calendar.compare(examDay, to: today, toGranularity: .day) == .orderedDescending else {
                print("⚠️ Exam date must be in the future")
                return
            }
            
            defaults.set(newDate, forKey: Key.examDate.rawValue)
        }
    }
}