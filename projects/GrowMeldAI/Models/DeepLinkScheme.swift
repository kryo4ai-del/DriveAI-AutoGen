// MARK: - Deep Link Schemes (Info.plist + Code)
/*
 URL Schemes:
 - driveai://category/verkehrszeichen
 - driveai://exam
 - driveai://question/q-12345
 - driveai://profile
 
 Web deep links (App Clips / Universal Links):
 - https://driveai.de/de/category/right-of-way
 - https://driveai.de/de/exam-simulator
 - https://driveai.de/de/learn/question/q-xyz
 */

struct DeepLinkScheme {
    static let scheme = "driveai"
    static let universalLinkDomain = "driveai.de"
    
    static func categoryLink(_ categoryId: String) -> URL {
        URL(string: "\(scheme)://category/\(categoryId)")!
    }
    
    static func questionLink(_ questionId: String) -> URL {
        URL(string: "\(scheme)://question/\(questionId)")!
    }
}