// DeepLinkManager.swift
import Foundation
import Combine

/// Protocol for deep link handling
protocol DeepLinkHandlerProtocol {
    func handleDeepLink(_ url: URL) -> Bool
    func canHandleDeepLink(_ url: URL) -> Bool
}

/// Deep link manager for DriveAI
final class DeepLinkManager: DeepLinkHandlerProtocol, ObservableObject {
    private let config: SEOConfiguration
    private var cancellables = Set<AnyCancellable>()

    init(config: SEOConfiguration = .default) {
        self.config = config
    }

    func handleDeepLink(_ url: URL) -> Bool {
        guard canHandleDeepLink(url) else { return false }

        // Handle different deep link patterns
        switch url.path {
        case "/exam":
            // Navigate to exam preparation
            NotificationCenter.default.post(name: .navigateToExam, object: nil)
        case "/lesson":
            // Navigate to specific lesson
            if let lessonId = url.queryParameters?["id"] {
                NotificationCenter.default.post(name: .navigateToLesson, object: lessonId)
            }
        case "/practice":
            // Navigate to practice mode
            NotificationCenter.default.post(name: .navigateToPractice, object: nil)
        default:
            return false
        }

        return true
    }

    func canHandleDeepLink(_ url: URL) -> Bool {
        // Validate URL scheme and host
        guard url.scheme == "driveai" else { return false }
        guard url.host == "app" else { return false }

        // Validate path
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