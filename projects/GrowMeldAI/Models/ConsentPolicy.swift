import Foundation

struct ConsentPolicy {
    let version: String
    let isEnabledInMVP: Bool
    init(version: String = "1.0", isEnabledInMVP: Bool = true) {
        self.version = version
        self.isEnabledInMVP = isEnabledInMVP
    }
}
