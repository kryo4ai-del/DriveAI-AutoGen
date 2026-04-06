// Services/Crashlytics/CrashSanitizer.swift
final class DefaultCrashSanitizer: CrashSanitizer {
    private let piiPatterns: [String: NSRegularExpression] = [
        "email": try! NSRegularExpression(
            pattern: "[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*",
            options: []
        ),
        "phone": try! NSRegularExpression(
            pattern: "\\+?[0-9]{1,3}[\\s.-]?(?:[0-9]{1,4}[\\s.-]?){1,3}[0-9]{1,4}",
            options: []
        ),
        "german_date": try! NSRegularExpression(
            pattern: "\\b([0-2]?[0-9]|3[01])\\.(0?[1-9]|1[0-2])\\.(19|20)?\\d{2}\\b",
            options: []
        ),
    ]
    
    func sanitize(_ text: String) -> String {
        var result = text
        
        for (_, regex) in piiPatterns {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(
                in: result,
                range: range,
                withTemplate: "[REDACTED]"
            )
        }
        
        return result
    }
}