import Crypto
  
  struct AuditLogSignature {
      static func sign(eventData: Data, key: SymmetricKey) -> Data {
          return Data(HMAC<SHA256>.authenticationCode(for: eventData, using: key))
      }
      
      static func verify(eventData: Data, signature: Data, key: SymmetricKey) -> Bool {
          let computed = HMAC<SHA256>.authenticationCode(for: eventData, using: key)
          return computed.withUnsafeBytes { ptr in
              memcmp(ptr.baseAddress!, [UInt8](signature), ptr.count) == 0
          }
      }
  }