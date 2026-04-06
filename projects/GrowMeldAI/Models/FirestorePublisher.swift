struct FirestorePublisher<T: Decodable>: Publisher {
    typealias Output = [T]
    typealias Failure = Error
    
    let db: Firestore
    let collection: String
    
    func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Error, S.Input == [T] {
        let subscription = FirestoreSubscription(
            db: db,
            collection: collection,
            subscriber: subscriber
        )
        subscriber.receive(subscription: subscription)
    }
}

class FirestoreSubscription<S: Subscriber, T: Decodable>: Subscription {
    private var listener: ListenerRegistration?
    
    func request(_ demand: Subscribers.Demand) {
        guard listener == nil else { return }
        
        listener = db.collection(collection)
            .addSnapshotListener { [weak self] snapshot, error in
                // ... emit
            }
    }
    
    func cancel() {
        listener?.remove()
        listener = nil
    }
}