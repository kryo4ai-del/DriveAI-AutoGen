struct UserFeedback: Codable {
    let contactOptIn: Bool
    private let contactEmail: String?
    private let contactPhone: String?
    
    // Custom encoding: only include contact info if opted in
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(contactOptIn, forKey: .contactOptIn)
        
        // ONLY encode contact info if opted in
        if contactOptIn {
            try container.encode(contactEmail, forKey: .contactEmail)
            try container.encode(contactPhone, forKey: .contactPhone)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, contactOptIn, contactEmail, contactPhone
    }
}