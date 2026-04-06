import Foundation
import Combine

@MainActor
class EpisodicalMemoryService: ObservableObject {
    @Published var memories: [EpisodicalMemory] = []
    @Published var isLoading = false
    @Published var error: ServiceError?
    
    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    enum ServiceError: LocalizedError {
        case decodingFailed
        case encodingFailed
        case fileAccessFailed
        case diskFull
        
        var errorDescription: String? {
            switch self {
            case .decodingFailed:
                return "Erinnerungen konnten nicht geladen werden"
            case .encodingFailed:
                return "Erinnerung konnte nicht gespeichert werden"
            case .fileAccessFailed:
                return "Dateizugriff fehlgeschlagen"
            case .diskFull:
                return "Speicherplatz voll"
            }
        }
    }
    
    init() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        self.fileURL = paths[0].appendingPathComponent("episodic_memories.json")
        
        // Configure JSON encoder
        self.encoder.dateEncodingStrategy = .iso8601
        self.encoder.outputFormatting = .prettyPrinted
        
        // Configure JSON decoder
        self.decoder.dateDecodingStrategy = .iso8601
        
        Task {
            await loadMemories()
        }
    }
    
    func loadMemories() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try decoder.decode([EpisodicalMemory].self, from: data)
            self.memories = decoded.sorted { $0.timestamp > $1.timestamp }
            self.error = nil
        } catch CocoaError.fileReadNoSuchFile {
            self.memories = []
            self.error = nil
        } catch {
            self.error = .decodingFailed
        }
    }
    
    /// ✅ Throw on failure, allowing caller to handle
    func addMemory(_ memory: EpisodicalMemory) async throws {
        let oldMemories = memories
        memories.insert(memory, at: 0)
        
        do {
            try await saveMemories()
        } catch {
            memories = oldMemories // Rollback on failure
            self.error = error as? ServiceError ?? .encodingFailed
            throw error
        }
    }
    
    func deleteMemory(_ id: UUID) async throws {
        let oldMemories = memories
        memories.removeAll { $0.id == id }
        
        do {
            try await saveMemories()
        } catch {
            memories = oldMemories // Rollback on failure
            self.error = error as? ServiceError ?? .encodingFailed
            throw error
        }
    }
    
    func updateMemory(_ memory: EpisodicalMemory) async throws {
        if let index = memories.firstIndex(where: { $0.id == memory.id }) {
            let oldMemories = memories
            memories[index] = memory
            
            do {
                try await saveMemories()
            } catch {
                memories = oldMemories // Rollback on failure
                self.error = error as? ServiceError ?? .encodingFailed
                throw error
            }
        }
    }
    
    func getInsightForCategory(_ categoryId: String, categoryName: String) -> MemoryInsight {
        let categoryMemories = memories.filter { $0.questionCategoryId == categoryId }
        let correctCount = categoryMemories.filter { $0.isCorrect }.count
        let successRate = categoryMemories.isEmpty ? 0 : Double(correctCount) / Double(categoryMemories.count)
        
        let patterns = calculateMistakePatterns(for: categoryId)
        let recent = Array(categoryMemories.prefix(5))
        
        return MemoryInsight(
            categoryId: categoryId,
            categoryName: categoryName,
            totalMemories: categoryMemories.count,
            correctCount: correctCount,
            successRate: successRate,
            recentMemories: recent,
            topMistakePatterns: patterns
        )
    }
    
    private func calculateMistakePatterns(for categoryId: String) -> [MistakePattern] {
        let incorrect = memories
            .filter { $0.questionCategoryId == categoryId && !$0.isCorrect }
            .reduce(into: [String: (count: Int, lastDate: Date)]()) { result, memory in
                let current = result[memory.questionId] ?? (0, memory.timestamp)
                result[memory.questionId] = (current.count + 1, memory.timestamp)
            }
        
        return incorrect
            .map { MistakePattern(questionId: $0.key, occurrenceCount: $0.value.count, lastOccurrence: $0.value.lastDate) }
            .sorted { $0.occurrenceCount > $1.occurrenceCount }
            .prefix(3)
            .map { $0 }
    }
    
    private func saveMemories() async throws {
        do {
            let data = try encoder.encode(memories)
            try data.write(to: fileURL, options: .atomic)
            self.error = nil
        } catch {
            if (error as NSError).code == NSFileWriteOutOfSpaceError {
                self.error = .diskFull
                throw ServiceError.diskFull
            } else {
                self.error = .encodingFailed
                throw ServiceError.encodingFailed
            }
        }
    }
}