import SwiftUI
import Foundation
import Combine

protocol BaseViewModel: ObservableObject {
    associatedtype Model

    var data: Model? { get set }
    var isLoading: Bool { get set }
    var error: String? { get set }

    func loadData() async
    func handleError(_ error: Error)
}
