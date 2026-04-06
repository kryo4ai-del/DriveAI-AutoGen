// Features/KIIdentifikation/Domain/Repositories/TrafficSignRepository.swift
import Combine

protocol TrafficSignRepository {
    func fetchSign(by mlLabelId: String) -> AnyPublisher<TrafficSign, RepositoryError>
    func fetchAllSigns() -> AnyPublisher<[TrafficSign], RepositoryError>
    func fetchLinkedQuestions(for sign: TrafficSign) -> AnyPublisher<[String], RepositoryError>
    func saveRecognitionHistory(_ recognition: TrafficSignRecognition) -> AnyPublisher<Void, RepositoryError>
    func getRecognitionHistory() -> AnyPublisher<[TrafficSignRecognition], RepositoryError>
}

enum RepositoryError: LocalizedError {
    case notFound
    case decodingError(String)
    case databaseError(String)
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Zeichen nicht gefunden"
        case .decodingError(let msg):
            return "Dekodierungsfehler: \(msg)"
        case .databaseError(let msg):
            return "Datenbankfehler: \(msg)"
        }
    }
}

class LocalTrafficSignRepository: TrafficSignRepository {
    private let localDataService: LocalDataService
    private var signCache: [String: TrafficSign] = [:]
    
    init(localDataService: LocalDataService) {
        self.localDataService = localDataService
    }
    
    func fetchSign(by mlLabelId: String) -> AnyPublisher<TrafficSign, RepositoryError> {
        if let cached = signCache[mlLabelId] {
            return Just(cached)
                .setFailureType(to: RepositoryError.self)
                .eraseToAnyPublisher()
        }
        
        return Future { [weak self] promise in
            do {
                let sign = try self?.localDataService.fetchTrafficSign(mlLabelId: mlLabelId)
                if let sign = sign {
                    self?.signCache[mlLabelId] = sign
                    promise(.success(sign))
                } else {
                    promise(.failure(.notFound))
                }
            } catch {
                promise(.failure(.databaseError(error.localizedDescription)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchAllSigns() -> AnyPublisher<[TrafficSign], RepositoryError> {
        Future { [weak self] promise in
            do {
                let signs = try self?.localDataService.fetchAllTrafficSigns() ?? []
                promise(.success(signs))
            } catch {
                promise(.failure(.databaseError(error.localizedDescription)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchLinkedQuestions(for sign: TrafficSign) -> AnyPublisher<[String], RepositoryError> {
        Just(sign.linkedQuestionIds)
            .setFailureType(to: RepositoryError.self)
            .eraseToAnyPublisher()
    }
    
    func saveRecognitionHistory(_ recognition: TrafficSignRecognition) -> AnyPublisher<Void, RepositoryError> {
        Future { [weak self] promise in
            do {
                try self?.localDataService.saveRecognitionHistory(recognition)
                promise(.success(()))
            } catch {
                promise(.failure(.databaseError(error.localizedDescription)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getRecognitionHistory() -> AnyPublisher<[TrafficSignRecognition], RepositoryError> {
        Future { [weak self] promise in
            do {
                let history = try self?.localDataService.getRecognitionHistory() ?? []
                promise(.success(history))
            } catch {
                promise(.failure(.databaseError(error.localizedDescription)))
            }
        }
        .eraseToAnyPublisher()
    }
}