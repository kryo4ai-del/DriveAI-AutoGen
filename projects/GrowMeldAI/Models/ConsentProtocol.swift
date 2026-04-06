protocol ConsentProtocol: Sendable {
  var isConsentGranted: Bool { get }
  var hasConsented: Bool { get } // true if user made explicit choice
  
  func requestConsent() async -> Bool
  func revokeConsent()
  func deleteAllData()
}
