// ViewModels/Base/RealtimeViewModel.swift
@MainActor
class RealtimeViewModel: ObservableObject {
    private var listeners: [ListenerRegistration] = []
    
    deinit {
        detachAllListeners()
    }
    
    func attachListener(
        for categoryId: String,
        handler: @escaping ([CategoryProgress]) -> Void
    ) {
        guard let registration = firestoreService.observeProgress(
            categoryId: categoryId,
            handler: handler
        ) else { return }
        
        listeners.append(registration)
    }
    
    func detachAllListeners() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }
}