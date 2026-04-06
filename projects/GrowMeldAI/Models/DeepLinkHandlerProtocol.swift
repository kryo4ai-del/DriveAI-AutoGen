import Foundation
import Combine

protocol DeepLinkHandlerProtocol {
    func handleDeepLink(_ url: URL) -> Bool
    func canHandleDeepLink(_ url: URL) -> Bool
}

struct SEOConfiguration {
    static let `default` = SEOConfiguration()
}

final class DeepLinkManager: DeepLinkHandlerProtocol, ObservableObject {
    private let config: SEOConfiguration
    private var cancellables = Set<AnyCancellable>()

    init(config: SEOConfiguration = .default) {
        self.config = config
    }

    func handleDeepLink(_ url: URL) -> Bool {
        guard canHandleDeepLink(url) else { return false }

        switch url.path {
        case "/exam":
            NotificationCenter.default.post(name: .navigateToExam, object: nil)
        case "/lesson":
            if let lessonId = url.queryParameters?["id"] {
                NotificationCenter.default.post(name: .navigateToLesson, object: lessonId)
            }
        case "/practice":
            NotificationCenter.default.post(name: .navigateToPractice, object: nil)
        default:
            return false
        }

        return true
    }

    func canHandleDeepLink(_ url: URL) -> Bool {
        guard url.scheme == "driveai" else { return false }
        guard url.host == "app" else { return false }
        let validPaths = ["/exam", "/lesson", "/practice"]
        return validPaths.contains(url.path)
    }
}

extension Notification.Name {
    static let navigateToExam = Notification.Name("NavigateToExam")
    static let navigateToLesson = Notification.Name("NavigateToLesson")
    static let navigateToPractice = Notification.Name("NavigateToPractice")
}

extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return nil
        }
        return components.queryItems?.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }
    }
}