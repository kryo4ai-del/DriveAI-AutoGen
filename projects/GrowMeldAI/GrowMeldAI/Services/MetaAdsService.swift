class MetaAdsService {
    private let consentManager: ConsentManaging
    private var metaSDKInstance: FBSDKCore?
    
    init(consentManager: ConsentManaging) {
        self.consentManager = consentManager
        // DO NOT initialize SDK here
    }
    
    func trackEvent(_ event: DriveAIEvent) {
        guard consentManager.hasUserConsent else {
            // Log to console in DEBUG, silently drop in RELEASE
            #if DEBUG
            print("⚠️ Event dropped: consent not granted. Event: \(event)")
            #endif
            return
        }
        
        guard let sdk = metaSDKInstance else {
            // SDK not initialized = consent never granted
            return
        }
        
        sdk.log(event)
    }
    
    // ONLY called by ConsentManager after user grants consent
    func initializeSDK() async -> Result<Void, MetaAdsError> {
        guard consentManager.hasUserConsent else {
            return .failure(.consentNotGranted)
        }
        
        do {
            metaSDKInstance = try await FBSDKCoreKit.initialize(
                applicationID: Config.metaAppID,
                clientToken: Config.metaClientToken
            )
            return .success(())
        } catch {
            return .failure(.initializationFailed(error))
        }
    }
}