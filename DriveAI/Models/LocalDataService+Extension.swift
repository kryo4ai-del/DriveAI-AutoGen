extension LocalDataService {
    func saveExamDate(_ date: Date) {
        // Persist to SQLite or UserDefaults
        UserDefaults.standard.set(date, forKey: "exam_date")
        // Or update LocalDataService internal state if using database
    }
    
    func loadExamDate() -> Date? {
        UserDefaults.standard.object(forKey: "exam_date") as? Date
    }
    
    func resetAllProgress() {
        // Clear all user answers, progress, streaks
        // Example for SQLite:
        // db.execute("DELETE FROM user_answers")
        // db.execute("DELETE FROM progress_tracking")
        
        // Or UserDefaults:
        UserDefaults.standard.removeObject(forKey: "user_answers")
        UserDefaults.standard.removeObject(forKey: "progress_data")
        
        // Notify observers
        objectWillChange.send()
    }
}