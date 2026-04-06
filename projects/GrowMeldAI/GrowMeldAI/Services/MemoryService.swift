// ❌ NO CONSENT FLOW
@MainActor
class MemoryService: ObservableObject {
    init(storage: MemoryStorageProvider) {
        self.storage = storage
        Task { await load() }  // ← Automatically loads and tracks progress
    }
}