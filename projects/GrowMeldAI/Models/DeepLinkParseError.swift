enum DeepLinkParseError: Error {
    case unknownPath(String)
    case malformedCategoryId(String)
}

private func parseDeepLink(_ path: String) throws -> NotificationPayload.DeepLink {
    if path.starts(with: "/category/") {
        let components = path.replacingOccurrences(of: "/category/", with: "").split(separator: "/")
        guard let categoryId = components.first, !categoryId.isEmpty else {
            throw DeepLinkParseError.malformedCategoryId(path)
        }
        return .practiceCategory(String(categoryId))
    } else if path == "/exam/simulate" {
        return .examSimulation
    } else if path == "/dashboard" {
        return .dashboard
    } else if path == "/profile" {
        return .profile
    } else {
        logger.error("Unknown deep link path: \(path)")
        throw DeepLinkParseError.unknownPath(path)
    }
}

// In handler:
private func parseNotificationPayload(from userInfo: [AnyHashable: Any]) throws -> NotificationPayload {
    guard
        let typeString = userInfo["type"] as? String,
        let type = NotificationType(rawValue: typeString),
        let title = userInfo["title"] as? String,
        let body = userInfo["body"] as? String
    else {
        throw NotificationError.decodingError("Missing required notification fields")
    }
    
    var deepLink: NotificationPayload.DeepLink?
    if let deepLinkPath = userInfo["deepLink"] as? String {
        do {
            deepLink = try parseDeepLink(deepLinkPath)
        } catch {
            logger.error("Failed to parse deep link '\(deepLinkPath)': \(error)")
            // Still deliver notification, just without deep link
            deepLink = nil
        }
    }
    
    return NotificationPayload(
        type: type,
        title: title,
        body: body,
        deepLink: deepLink,
        badge: userInfo["badge"] as? Int,
        data: userInfo as? [String: String]
    )
}