import Foundation

extension GrowMeldAI.ConsentPreference {
    func withTimestamp(granted: Bool) -> GrowMeldAI.ConsentPreference {
        GrowMeldAI.ConsentPreference(
            id: self.id,
            category: self.category,
            titleKey: self.titleKey,
            descriptionKey: self.descriptionKey,
            isGranted: granted,
            grantedAt: granted ? Date() : self.grantedAt,
            revokedAt: !granted ? Date() : self.revokedAt,
            policyVersion: self.policyVersion
        )
    }
}