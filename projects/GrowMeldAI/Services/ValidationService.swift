// Core/Utilities/ValidationService.swift

struct ValidationService {
    static let shared = ValidationService()
    
    private let emailRegex: NSRegularExpression = {
        let pattern = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        return try! NSRegularExpression(pattern: pattern)
    }()
    
    private let passwordMinLength = 6
    private let nameMinLength = 2
    private let nameMaxLength = 100
    private let emailMaxLength = 254
    
    func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, trimmed.count <= emailMaxLength else { return false }
        
        let range = NSRange(trimmed.startIndex..., in: trimmed)
        return emailRegex.firstMatch(in: trimmed, range: range) != nil
    }
    
    func isValidPassword(_ password: String) -> Bool {
        password.count >= passwordMinLength && password.count <= 128
    }
    
    func isPasswordMatch(_ password: String, _ confirmPassword: String) -> Bool {
        password == confirmPassword && !password.isEmpty
    }
    
    func isValidFullName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        return trimmed.count >= nameMinLength && trimmed.count <= nameMaxLength
    }
}