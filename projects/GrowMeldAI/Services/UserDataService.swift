// Core/Services/UserDataService/UserDataService.swift
import Foundation
import os.log

class UserDataService: ObservableObject {
    @Published var userProfile: UserProfile
    
    private let userDefaultsKey = "com.driveai.userprofile"
    private let resultsDefaultsKey = "com.driveai.results"
    private let resultsQueue = DispatchQueue(
        label: "com.driveai.userdata",
        attributes: .concurrent
    )
    
    private var results: [QuestionResult] = []
    private let persistLock = NSLock()
    
    init() {
        // Load profile from persistence
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: savedData) {
            self.userProfile = decoded
        } else {
            self.userProfile = UserProfile(examDate: Date().addingTimeInterval(86400 * 60))
        }
        
        loadResults()
    }
    
    private func loadResults() {
        if let data = UserDefaults.standard.data(forKey: resultsDefaultsKey),
           let decoded = try? JSONDecoder().decode([QuestionResult].self, from: data) {
            resultsQueue.async(flags: .barrier) {
                self.results = decoded
            }
        }
    }
    
    // FIXED: Proper ordering - persist first, then update UI state
    func recordQuestionResult(_ result: QuestionResult) {
        resultsQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            // 1. Add result to in-memory cache
            self.results.append(result)
            
            // 2. Persist results immediately
            self.persistLock.lock()
            if let encoded = try? JSONEncoder().encode(self.results) {
                UserDefaults.standard.set(encoded, forKey: self.resultsDefaultsKey)
            }
            self.persistLock.unlock()
            
            // 3. Update profile on main thread AFTER persist
            DispatchQueue.main.async {
                self.updateProfile(with: result)
            }
        }
    }
    
    // FIXED: Separated concerns - profile updates don't call persist()
    private func updateProfile(with result: QuestionResult) {
        // Update counts
        userProfile.totalQuestionsAnswered += 1
        
        if result.isCorrect {
            userProfile.correctAnswers += 1
            userProfile.currentStreak += 1
            userProfile.longestStreak = max(userProfile.longestStreak, userProfile.currentStreak)
        } else {
            userProfile.currentStreak = 0
        }
        
        // Update category progress
        var categoryProg = userProfile.categoryProgress[result.categoryId]
            ?? CategoryProgress(categoryId: result.categoryId)
        
        categoryProg.questionsAnswered += 1
        if result.isCorrect {
            categoryProg.correctAnswers += 1
        }
        userProfile.categoryProgress[result.categoryId] = categoryProg
        
        userProfile.lastActivityDate = Date()
        
        // Persist profile
        persistUserProfile()
        
        // Notify observers
        self.objectWillChange.send()
    }
    
    private func persistUserProfile() {
        persistLock.lock()
        defer { persistLock.unlock() }
        
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        } else {
            os_log("Failed to persist user profile", type: .error)
        }
    }
    
    func getResults(for categoryId: String? = nil) -> [QuestionResult] {
        var filtered: [QuestionResult] = []
        resultsQueue.sync {
            if let categoryId = categoryId {
                filtered = results.filter { $0.categoryId == categoryId }
            } else {
                filtered = results
            }
        }
        return filtered
    }
    
    func clearAllData() {
        resultsQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.results = []
            self.persistLock.lock()
            UserDefaults.standard.removeObject(forKey: self.resultsDefaultsKey)
            self.persistLock.unlock()
        }
        
        userProfile = UserProfile(examDate: Date().addingTimeInterval(86400 * 60))
        persistUserProfile()
    }
}