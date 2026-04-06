// ❌ String-based, prone to typos
shareMethod: String // "twitter", "whatsapp"

// ✅ Type-safe
enum ShareMethod: String, Codable {
    case twitter, whatsapp, mail, copy, more
}
