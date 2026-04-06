struct FirestoreCollectionPublisher<T: Decodable>: Publisher {
    typealias Output = [T]
    typealias Failure = Error
    
    private let db: Firestore
    private let collection: String
    
    func receive<S>(subscriber: S) where S: Subscriber, 
        S.Failure == Failure, S.Input == Output {
        let subscription = FirestoreCollectionSubscription(
            db: db,
            collection: collection,
            subscriber: subscriber
        )
        subscriber.receive(subscription: subscription)
    }
}

private class FirestoreCollectionSubscription<S: Subscriber, T: Decodable>: Subscription 
where S.Input == [T], S.Failure == Error {
    private var listener: ListenerRegistration?
    
    init(db: Firestore, collection: String, subscriber: S) {
        listener = db.collection(collection).addSnapshotListener { snapshot, error in
            if let error = error {
                subscriber.receive(completion: .failure(error))
                return
            }
            
            guard let snapshot = snapshot else { return }
            let documents = snapshot.documents.compactMap { try? $0.data(as: T.self) }
            _ = subscriber.receive(documents)
        }
    }
    
    func request(_ demand: Subscribers.Demand) {
        // Listener already active from init
    }
    
    func cancel() {
        listener?.remove()
        listener = nil
    }
}