// MARK: - Services/Implementations/DefaultLocalDataService.swift
import Foundation

final class DefaultLocalDataService: LocalDataService {
    private let fileManager = FileManager.default
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private var cachedQuestions: [Question]?
    private var cachedProgress: UserProgress?
    private let cacheLock = NSLock()

    private var questionsCacheURL: URL {
        let documentsURL = try! fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return documentsURL.appendingPathComponent("questions.json")
    }

    private var progressCacheURL: URL {
        let documentsURL = try! fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return documentsURL.appendingPathComponent("progress.json")
    }

    init() {
        encoder.outputFormatting = .prettyPrinted
    }

    func loadQuestions() async throws -> [Question] {
        cacheLock.lock()
        defer { cacheLock.unlock() }

        if let cached = cachedQuestions {
            return cached
        }

        do {
            let data = try Data(contentsOf: questionsCacheURL)
            let questions = try decoder.decode([Question].self, from: data)
            cachedQuestions = questions
            return questions
        } catch {
            // Fallback to bundle if cache fails
            let bundleURL = Bundle.main.url(forResource: "questions", withExtension: "json")!
            let data = try Data(contentsOf: bundleURL)
            let questions = try decoder.decode([Question].self, from: data)
            cachedQuestions = questions
            return questions
        }
    }

    func questions(for categoryId: String) async throws -> [Question] {
        let questions = try await loadQuestions()
        return questions.filter { $0.categoryId == categoryId }
    }

    func question(byId id: String) async throws -> Question {
        let questions = try await loadQuestions()
        guard let question = questions.first(where: { $0.id == id }) else {
            throw AppError.invalidQuestion(id)
        }
        return question
    }

    func search(_ term: String) async throws -> [Question] {
        let questions = try await loadQuestions()
        return questions.filter { $0.text.localizedCaseInsensitiveContains(term) }
    }

    func loadProgress() async throws -> UserProgress {
        cacheLock.lock()
        defer { cacheLock.unlock() }

        if let cached = cachedProgress {
            return cached
        }

        do {
            let data = try Data(contentsOf: progressCacheURL)
            let progress = try decoder.decode(UserProgress.self, from: data)
            cachedProgress = progress
            return progress
        } catch {
            // Return fresh progress if loading fails
            let progress = UserProgress()
            try await saveProgress(progress)
            cachedProgress = progress
            return progress
        }
    }

    func saveProgress(_ progress: UserProgress) async throws {
        cacheLock.lock()
        defer { cacheLock.unlock() }

        do {
            let data = try encoder.encode(progress)
            try data.write(to: progressCacheURL)
            cachedProgress = progress
        } catch {
            throw AppError.corruptedProgress
        }
    }

    func clearCache() async {
        cacheLock.lock()
        defer { cacheLock.unlock() }

        cachedQuestions = nil
        cachedProgress = nil

        try? fileManager.removeItem(at: questionsCacheURL)
        try? fileManager.removeItem(at: progressCacheURL)
    }
}