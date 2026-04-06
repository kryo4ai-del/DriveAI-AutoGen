struct ConsentAuditLog: Codable {
       let action: ConsentAction  // .granted, .denied, .withdrawn
       let timestamp: Date
       let deviceId: String?  // Pseudonymized identifier
   }