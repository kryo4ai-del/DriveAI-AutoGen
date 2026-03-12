import Foundation
import Combine

// Protocol representing Local Data Service
protocol LocalDataServiceProtocol {
    func fetchQuestions() throws -> [Question]
}
