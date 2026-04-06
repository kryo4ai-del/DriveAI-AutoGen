class NotificationHandlerService: NSObject, UNUserNotificationCenterDelegate {
    private weak var delegateWeakRef: UNUserNotificationCenterDelegate?
    var notificationReceived: ((NotificationPayload) -> Void)?
    
    deinit {
        UNUserNotificationCenter.current().delegate = nil
        logger.info("NotificationHandlerService deallocated")
    }
    
    func setup() {
        UNUserNotificationCenter.current().delegate = self
        logger.info("NotificationHandlerService registered as delegate")
    }
}

// Manage lifecycle explicitly:
@main

class NotificationHandlerServiceContainer: ObservableObject {
    let handler: NotificationHandlerService
    
    init() {
        self.handler = NotificationHandlerService(
            auditService: NotificationPersistenceService(),
            deepLinkHandler: DeepLinkHandler()
        )
    }
    
    deinit {
        UNUserNotificationCenter.current().delegate = nil
    }
}