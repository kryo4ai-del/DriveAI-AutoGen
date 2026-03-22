enum AccessPoint {
    case homeScreenButton
    case notificationTap(notificationID: String)
    case deepLink(url: URL)
    case siriShortcut
}