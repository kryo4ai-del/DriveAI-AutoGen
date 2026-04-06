import Foundation
import os.log

private let logger = Logger(subsystem: "com.driveai.data", category: "localdata")

final class LocalDataServiceImplementation: LocalDataServiceProtocol, Sendable {
  private nonisolated(unsafe) var cachedCategories: [Category]?
  private nonisolated(unsafe) var cachedQuestions: [String: [Question]] = [:]
  private nonisolated(unsafe) var cacheExpiry: Date = .distantPast
  
  private let cacheDuration: TimeInterval = 3600 // 1 hour
  private let fileManager = FileManager.default
  private let decoder: JSONDecoder
  private let backgroundQueue = DispatchQueue(
    label: "com.driveai.data.background",
    qos: .userInitiated
  )
  
  init() {
    self.decoder = JSONDecoder()
    self.decoder.dateDecodingStrategy = .iso8601
  }
  
  // MARK: - Public Methods
  
  nonisolated func fetchAllCategories() async throws -> [Category] {
    // Check cache validity
    if Date() < cachedCategories.map { _ in cacheExpiry } ?? .distantPast {
      if let cached = cachedCategories {
        return cached
      }
    }
    
    // Load from background queue
    return try await Task.detached(priority: .userInitiated) { [weak self] () -> [Category] in
      guard let self else {
        throw LocalDataServiceError.invalidData("Service deallocated")
      }
      let categories = try self.loadCategoriesFromBundle()
      
      // Update cache on main thread to avoid race condition
      await MainActor.run { [weak self] in
        self?.cachedCategories = categories
        self?.cacheExpiry = Date().addingTimeInterval(self?.cacheDuration ?? 3600)
      }
      
      return categories
    }.value
  }
  
  nonisolated func fetchQuestions(for categoryId: String) async throws -> [Question] {
    // Check if questions for this category are cached
    if Date() < cacheExpiry, let cached = cachedQuestions[categoryId] {
      return cached
    }
    
    return try await Task.detached(priority: .userInitiated) { [weak self] () -> [Question] in
      guard let self else {
        throw LocalDataServiceError.invalidData("Service deallocated")
      }
      
      let allQuestions = try self.loadQuestionsFromBundle()
      let filtered = allQuestions.filter { $0.categoryId == categoryId }
      
      guard !filtered.isEmpty else {
        throw LocalDataServiceError.noQuestionsAvailable
      }
      
      // Update cache
      await MainActor.run { [weak self] in
        self?.cachedQuestions[categoryId] = filtered
      }
      
      return filtered
    }.value
  }
  
  nonisolated func fetchRandomQuestions(count: Int) async throws -> [Question] {
    return try await Task.detached(priority: .userInitiated) { [weak self] () -> [Question] in
      guard let self else {
        throw LocalDataServiceError.invalidData("Service deallocated")
      }
      
      let allQuestions = try self.loadQuestionsFromBundle()
      
      guard allQuestions.count >= count else {
        throw LocalDataServiceError.invalidData(
          "Requested \(count) questions, but only \(allQuestions.count) available"
        )
      }
      
      return Array(allQuestions.shuffled().prefix(count))
    }.value
  }
  
  nonisolated func getQuestionById(_ id: String) async throws -> Question? {
    return try await Task.detached(priority: .userInitiated) { [weak self] () -> Question? in
      guard let self else { return nil }
      let allQuestions = try self.loadQuestionsFromBundle()
      return allQuestions.first { $0.id == id }
    }.value
  }
  
  nonisolated func getCategoryById(_ id: String) async throws -> Category? {
    return try await Task.detached(priority: .userInitiated) { [weak self] () -> Category? in
      guard let self else { return nil }
      let categories = try self.loadCategoriesFromBundle()
      return categories.first { $0.id == id }
    }.value
  }
  
  nonisolated func seedInitialDataIfNeeded() async throws {
    // Validates that data is decodable and valid
    _ = try await fetchAllCategories()
    
    // Fetch at least one category to verify questions exist
    let allCategories = try await fetchAllCategories()
    guard !allCategories.isEmpty else {
      throw LocalDataServiceError.invalidData("No categories found in seed data")
    }
    
    // Verify at least one question per category
    for category in allCategories {
      let questions = try await fetchQuestions(for: category.id)
      guard !questions.isEmpty else {
        throw LocalDataServiceError.invalidData(
          "Category '\(category.name)' has no questions"
        )
      }
    }
    
    logger.info("✅ Seed data validated successfully")
  }
  
  // MARK: - Private Methods
  
  private nonisolated func loadCategoriesFromBundle() throws -> [Category] {
    guard let url = Bundle.main.url(forResource: "categories", withExtension: "json") else {
      logger.error("❌ categories.json not found in Bundle")
      throw LocalDataServiceError.fileNotFound("categories.json")
    }
    
    let data = try Data(contentsOf: url)
    
    do {
      let categories = try decoder.decode([Category].self, from: data)
      logger.debug("Loaded \(categories.count) categories")
      return categories
    } catch {
      logger.error("Failed to decode categories: \(error, privacy: .public)")
      throw LocalDataServiceError.decodingFailed("categories.json: \(error.localizedDescription)")
    }
  }
  
  private nonisolated func loadQuestionsFromBundle() throws -> [Question] {
    guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
      logger.error("❌ questions.json not found in Bundle")
      throw LocalDataServiceError.fileNotFound("questions.json")
    }
    
    let data = try Data(contentsOf: url)
    
    do {
      let questions = try decoder.decode([Question].self, from: data)
      logger.debug("Loaded \(questions.count) questions")
      return questions
    } catch {
      logger.error("Failed to decode questions: \(error, privacy: .public)")
      throw LocalDataServiceError.decodingFailed("questions.json: \(error.localizedDescription)")
    }
  }
}