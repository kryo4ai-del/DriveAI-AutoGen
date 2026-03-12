import Foundation

protocol DataServiceProtocol {
    func loadQuestions(completion: @escaping ([Question]) -> Void)
}
