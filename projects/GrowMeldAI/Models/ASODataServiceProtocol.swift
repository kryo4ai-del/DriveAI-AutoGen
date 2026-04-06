import Foundation

protocol ASODataServiceProtocol {
    func getKeywordRankings() async throws -> [String: Int]
}
