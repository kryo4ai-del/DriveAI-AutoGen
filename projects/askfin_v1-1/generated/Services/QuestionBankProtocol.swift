import Foundation

protocol QuestionBankProtocol {
    func randomQuestion(for topic: TopicArea, revealMode: RevealMode) -> SessionQuestion?
    func questions(for topic: TopicArea) -> [SessionQuestion]
}