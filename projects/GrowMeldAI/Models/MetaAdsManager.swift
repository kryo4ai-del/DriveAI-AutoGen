@MainActor
class MetaAdsManager: NSObject {
  static let shared = MetaAdsManager()
  
  private let consentManager: ConsentManager
  private let configuration: MetaAdsConfiguration
  private let logger: AnalyticsLogger
  
  private var eventQueue: [MetaAnalyticsEvent] = []
  private var isInitialized = false
  
  override init() {
    self.consentManager = ConsentManager()
    self.configuration = MetaAdsConfiguration.current
    self.logger = AnalyticsLogger()
  }
  
  // Called from @main app during launch
  func initialize() {
    // Initialize Meta SDK only if app-wide consent is granted
    guard consentManager.isConsentGranted else {
      logger.info("Meta SDK init skipped: no user consent")
      return
    }
    
    // Configure Meta SDK
    FBSDKCoreKit.ApplicationDelegate.shared.initialize()
    FBSDKCoreKit.Settings.appID = configuration.appID
    FBSDKCoreKit.Settings.clientToken = configuration.clientToken
    
    // Request IDFA (iOS 14.5+) if user consented
    requestIDFA()
    
    isInitialized = true
    
    // Flush any queued events
    flushEventQueue()
  }
  
  // Main entry point for logging app events
  func log(_ event: MetaAnalyticsEvent) {
    if consentManager.isConsentGranted {
      logEvent(event)
    } else {
      eventQueue.append(event) // Queue until consent granted
    }
  }
  
  // Send event to Meta SDK
  private func logEvent(_ event: MetaAnalyticsEvent) {
    guard isInitialized else {
      logger.warn("Meta SDK not initialized")
      return
    }
    
    let fbEvent = event.toFBEvent() // Convert domain event to Meta event
    FBSDKCoreKit.AppEvents.shared.logEvent(fbEvent)
  }
  
  // Flush queued events after user grants consent
  private func flushEventQueue() {
    for event in eventQueue {
      logEvent(event)
    }
    eventQueue.removeAll()
  }
  
  private func requestIDFA() {
    // ATT (App Tracking Transparency) request
    // Only if user hasn't already been asked
    #if os(iOS) && !targetEnvironment(simulator)
    Task {
      await ATTrackingManager.requestTrackingAuthorization()
    }
    #endif
  }
}