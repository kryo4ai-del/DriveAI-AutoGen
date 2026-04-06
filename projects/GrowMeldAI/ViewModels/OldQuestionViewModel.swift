import SwiftUI
import Foundation
import Combine
class OldQuestionViewModel: ObservableObject {
    @Published var currentQuestion: Question?
    @Published var selectedAnswer: Int?
    // ❌ Manual @Published, NSObject overhead
}