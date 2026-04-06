import Foundation

struct UserFeedback: Codable {
    let id: String
    let contactOptIn: Bool
    private let contactEmail: String?
    private let contactPhone: String?

    init(id: String = UUID().uuidString,
         contactOptIn: Bool,
         contactEmail: String? = nil,
         contactPhone: String? = nil) {
        self.id = id
        self.contactOptIn = contactOptIn
        self.contactEmail = contactEmail
        self.contactPhone = contactPhone
    }

    enum CodingKeys: String, CodingKey {
        case id
        case contactOptIn
        case contactEmail
        case contactPhone
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        contactOptIn = try container.decode(Bool.self, forKey: .contactOptIn)
        contactEmail = try container.decodeIfPresent(String.self, forKey: .contactEmail)
        contactPhone = try container.decodeIfPresent(String.self, forKey: .contactPhone)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(contactOptIn, forKey: .contactOptIn)
        if contactOptIn {
            try container.encodeIfPresent(contactEmail, forKey: .contactEmail)
            try container.encodeIfPresent(contactPhone, forKey: .contactPhone)
        }
    }
}