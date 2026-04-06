// Services/QuestionResultPersistenceService.swift
import CoreData

protocol QuestionResultPersistenceProtocol {
    func saveResult(_ result: QuestionResult) async throws
    func fetchResults(userId: String, limit: Int, offset: Int) async -> [QuestionResult]
    func fetchResultsSince(_ date: Date, userId: String) async -> [QuestionResult]
    func countCorrectAnswers(userId: String, category: QuestionCategory) async -> Int
}

class CoreDataQuestionResultService: QuestionResultPersistenceProtocol {
    static let shared = CoreDataQuestionResultService()
    
    private let container: NSPersistentContainer
    private let backgroundContext: NSManagedObjectContext
    
    init() {
        container = NSPersistentContainer(name: "DriveAI")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("CoreData initialization failed: \(error)")
            }
        }
        
        backgroundContext = container.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrustMakingStrategy
    }
    
    func saveResult(_ result: QuestionResult) async throws {
        let context = backgroundContext
        
        return try await context.perform {
            let entity = NSEntityDescription.entity(forEntityName: "QuestionResultEntity", in: context)!
            let nsObject = NSManagedObject(entity: entity, insertInto: context)
            
            nsObject.setValue(result.id, forKey: "id")
            nsObject.setValue(result.questionId, forKey: "questionId")
            nsObject.setValue(result.userId, forKey: "userId")
            nsObject.setValue(result.selectedAnswerIndex, forKey: "selectedAnswerIndex")
            nsObject.setValue(result.isCorrect, forKey: "isCorrect")
            nsObject.setValue(result.timeSpentSeconds, forKey: "timeSpentSeconds")
            nsObject.setValue(result.answeredAt, forKey: "answeredAt")
            
            try context.save()
        }
    }
    
    func fetchResults(userId: String, limit: Int = 50, offset: Int = 0) async -> [QuestionResult] {
        let context = backgroundContext
        
        return await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "QuestionResultEntity")
            request.predicate = NSPredicate(format: "userId == %@", userId)
            request.sortDescriptors = [NSSortDescriptor(key: "answeredAt", ascending: false)]
            request.fetchLimit = limit
            request.fetchOffset = offset
            
            guard let objects = try? context.fetch(request) else { return [] }
            
            return objects.compactMap { obj in
                QuestionResult(
                    id: obj.value(forKey: "id") as? String ?? "",
                    questionId: obj.value(forKey: "questionId") as? String ?? "",
                    userId: obj.value(forKey: "userId") as? String ?? "",
                    selectedAnswerIndex: obj.value(forKey: "selectedAnswerIndex") as? Int ?? 0,
                    isCorrect: obj.value(forKey: "isCorrect") as? Bool ?? false,
                    timeSpentSeconds: obj.value(forKey: "timeSpentSeconds") as? Int ?? 0,
                    answeredAt: obj.value(forKey: "answeredAt") as? Date ?? Date()
                )
            }
        }
    }
    
    func fetchResultsSince(_ date: Date, userId: String) async -> [QuestionResult] {
        let context = backgroundContext
        
        return await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "QuestionResultEntity")
            request.predicate = NSPredicate(format: "userId == %@ AND answeredAt >= %@", userId, date as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "answeredAt", ascending: true)]
            
            guard let objects = try? context.fetch(request) else { return [] }
            
            return objects.compactMap { obj in
                QuestionResult(
                    id: obj.value(forKey: "id") as? String ?? "",
                    questionId: obj.value(forKey: "questionId") as? String ?? "",
                    userId: obj.value(forKey: "userId") as? String ?? "",
                    selectedAnswerIndex: obj.value(forKey: "selectedAnswerIndex") as? Int ?? 0,
                    isCorrect: obj.value(forKey: "isCorrect") as? Bool ?? false,
                    timeSpentSeconds: obj.value(forKey: "timeSpentSeconds") as? Int ?? 0,
                    answeredAt: obj.value(forKey: "answeredAt") as? Date ?? Date()
                )
            }
        }
    }
    
    func countCorrectAnswers(userId: String, category: QuestionCategory) async -> Int {
        let context = backgroundContext
        
        return await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "QuestionResultEntity")
            request.predicate = NSPredicate(format: "userId == %@ AND isCorrect == true", userId)
            
            return (try? context.count(for: request)) ?? 0
        }
    }
}