public struct PrivacyNotice: Codable {
    public let experimentName: String
    public let hypothesis: String
    public let whatWeCollect: String  // "Answer timing, accuracy, and satisfaction rating"
    public let whyWeCollect: String  // "To optimize the learning experience"
    public let howLong: String       // "Metrics retained for 90 days"
    public let userRights: [String]  // ["Access", "Portability", "Deletion", "Opt-out"]
    public let contactEmail: String  // data-protection@company.com
    
    public init?(from experiment: Experiment) {
        // Generate privacy notice from experiment metadata
        self.experimentName = experiment.name
        self.hypothesis = experiment.hypothesis
        self.whatWeCollect = "Your answers, response time, and learning speed in this test"
        self.whyWeCollect = "To find the best way to help you prepare for your driving exam"
        self.howLong = "Data deleted 90 days after the test ends"
        self.userRights = ["View your data", "Delete your data", "Opt out of testing"]
        self.contactEmail = "support@driveai.app"
    }
}