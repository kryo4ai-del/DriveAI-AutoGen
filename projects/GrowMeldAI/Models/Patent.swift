// Patent.swift
import Foundation

/// Represents a patent document with legal compliance tracking
struct Patent: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let abstract: String
    let filingDate: Date
    let legalStatus: LegalStatus
    let sourceAuthority: SourceAuthority
    let licenseStatus: LicenseStatus
    let lastVerifiedDate: Date
    let verificationVersion: String

    enum LegalStatus: String, Codable, CaseIterable {
        case pending
        case granted
        case expired
        case revoked
        case lapsed
    }

    enum SourceAuthority: String, Codable, CaseIterable {
        case epo // European Patent Office
        case uspto // United States Patent and Trademark Office
        case jpo // Japan Patent Office
        case de // German Patent and Trade Mark Office
        case unknown
    }

    enum LicenseStatus: String, Codable, CaseIterable {
        case publicDomain = "public_domain"
        case ccBy = "cc_by"
        case ccBySa = "cc_by_sa"
        case proprietary
        case restricted
        case unknown
    }
}

// MARK: - Patent Verification
extension Patent {
    /// Verifies the patent against current legal standards
    func verify() -> VerificationResult {
        // In a real implementation, this would call external legal databases
        // For now, return a mock verification result
        let isCurrent = Calendar.current.date(byAdding: .year, value: -5, to: filingDate) ?? Date() > Date()
        let isValidStatus = legalStatus != .revoked && legalStatus != .expired

        return VerificationResult(
            isVerified: isCurrent && isValidStatus,
            verificationDate: Date(),
            notes: isCurrent ? nil : "Filing date too old",
            status: isCurrent && isValidStatus ? .valid : .invalid
        )
    }
}

// MARK: - Patent Repository Protocol
protocol PatentRepository {
    func fetchPatents() async throws -> [Patent]
    func fetchPatent(by id: UUID) async throws -> Patent?
    func searchPatents(query: String) async throws -> [Patent]
    func savePatent(_ patent: Patent) async throws
    func deletePatent(_ id: UUID) async throws
}

// MARK: - Local Patent Repository (Offline-first)
final class LocalPatentRepository: PatentRepository {
    private let persistenceController: PersistenceController
    private let verificationService: PatentVerificationService

    init(persistenceController: PersistenceController = .shared,
         verificationService: PatentVerificationService = .shared) {
        self.persistenceController = persistenceController
        self.verificationService = verificationService
    }

    func fetchPatents() async throws -> [Patent] {
        let context = persistenceController.container.viewContext
        let request = PatentEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PatentEntity.filingDate, ascending: false)]

        let entities = try context.fetch(request)
        return entities.compactMap { $0.toDomain() }
    }

    func fetchPatent(by id: UUID) async throws -> Patent? {
        let context = persistenceController.container.viewContext
        let request = PatentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        let entities = try context.fetch(request)
        return entities.first?.toDomain()
    }

    func searchPatents(query: String) async throws -> [Patent] {
        let context = persistenceController.container.viewContext
        let request = PatentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR abstract CONTAINS[cd] %@", query, query)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PatentEntity.title, ascending: true)]

        let entities = try context.fetch(request)
        return entities.compactMap { $0.toDomain() }
    }

    func savePatent(_ patent: Patent) async throws {
        let context = persistenceController.container.viewContext
        let entity = PatentEntity(context: context)
        entity.update(from: patent)

        // Verify the patent before saving
        let verification = patent.verify()
        entity.verificationStatus = verification.status.rawValue
        entity.lastVerifiedDate = verification.verificationDate

        try context.save()
    }

    func deletePatent(_ id: UUID) async throws {
        let context = persistenceController.container.viewContext
        let request = PatentEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        let entities = try context.fetch(request)
        entities.forEach { context.delete($0) }

        try context.save()
    }
}

// MARK: - Patent Verification Service
final class PatentVerificationService {
    static let shared = PatentVerificationService()

    private init() {} // Singleton

    func verifyPatent(_ patent: Patent) async -> VerificationResult {
        // Simulate network verification
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay

        // Mock verification logic
        let isCurrent = Calendar.current.date(byAdding: .year, value: -5, to: patent.filingDate) ?? Date() > Date()
        let isValidStatus = patent.legalStatus != .revoked && patent.legalStatus != .expired

        return VerificationResult(
            isVerified: isCurrent && isValidStatus,
            verificationDate: Date(),
            notes: isCurrent ? nil : "Filing date too old",
            status: isCurrent && isValidStatus ? .valid : .invalid
        )
    }
}

// MARK: - Core Data Model
@objc(PatentEntity)
final class PatentEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var abstract: String
    @NSManaged var filingDate: Date
    @NSManaged var legalStatusRaw: String
    @NSManaged var sourceAuthorityRaw: String
    @NSManaged var licenseStatusRaw: String
    @NSManaged var lastVerifiedDate: Date?
    @NSManaged var verificationStatus: String?
    @NSManaged var verificationVersion: String?

    func toDomain() -> Patent? {
        guard let legalStatus = Patent.LegalStatus(rawValue: legalStatusRaw),
              let sourceAuthority = Patent.SourceAuthority(rawValue: sourceAuthorityRaw),
              let licenseStatus = Patent.LicenseStatus(rawValue: licenseStatusRaw) else {
            return nil
        }

        return Patent(
            id: id,
            title: title,
            abstract: abstract,
            filingDate: filingDate,
            legalStatus: legalStatus,
            sourceAuthority: sourceAuthority,
            licenseStatus: licenseStatus,
            lastVerifiedDate: lastVerifiedDate ?? Date(),
            verificationVersion: verificationVersion ?? "1.0"
        )
    }

    func update(from patent: Patent) {
        id = patent.id
        title = patent.title
        abstract = patent.abstract
        filingDate = patent.filingDate
        legalStatusRaw = patent.legalStatus.rawValue
        sourceAuthorityRaw = patent.sourceAuthority.rawValue
        licenseStatusRaw = patent.licenseStatus.rawValue
        lastVerifiedDate = patent.lastVerifiedDate
        verificationVersion = patent.verificationVersion
    }
}

// MARK: - Persistence Controller
final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PatentSearch")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func save() throws {
        let context = container.viewContext
        if context.hasChanges {
            try context.save()
        }
    }
}