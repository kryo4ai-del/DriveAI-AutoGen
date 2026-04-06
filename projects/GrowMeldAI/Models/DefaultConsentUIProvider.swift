import UIKit

@MainActor
final class DefaultConsentUIProvider: ConsentUIProvider {
    func presentConsentUI() async -> Bool {
        return await withCheckedContinuation { [weak self] continuation in
            DispatchQueue.main.async {
                guard let self else {
                    continuation.resume(returning: false)
                    return
                }
                
                let controller = self.makeConsentAlertController { granted in
                    continuation.resume(returning: granted)
                }
                
                // Add accessibility for entire alert
                controller.view.accessibilityLabel = "Datenschutz-Genehmigung"
                controller.view.accessibilityHint = "Sie werden gefragt, ob DriveAI Ihre App-Nutzungsdaten mit Meta Ads teilen darf. Ihre Prüfungsergebnisse werden NICHT geteilt."
                
                if let window = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first?.windows
                    .first(where: { $0.isKeyWindow }),
                   let rootVC = window.rootViewController {
                    rootVC.present(controller, animated: true)
                }
            }
        }
    }
    
    private func makeConsentAlertController(
        completion: @escaping (Bool) -> Void
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: "Daten & Datenschutz",
            message: """
            DriveAI nutzt anonymisierte Daten, um die App zu verbessern.
            
            Deine Prüfungsergebnisse werden nicht mit Meta Ads geteilt.
            
            Mehr: Einstellungen → Datenschutz
            """,
            preferredStyle: .alert
        )
        
        // FIXED: Add accessibility hints to actions
        let acceptAction = UIAlertAction(
            title: "Akzeptieren",
            style: .default
        ) { _ in
            completion(true)
        }
        acceptAction.accessibilityHint = "Erlaubt DriveAI, Daten zum Verbessern der App zu nutzen"
        
        let denyAction = UIAlertAction(
            title: "Ablehnen",
            style: .cancel
        ) { _ in
            completion(false)
        }
        denyAction.accessibilityHint = "Verhindert Datensharing mit Meta Ads. Sie können dies später in Einstellungen ändern."
        
        alert.addAction(acceptAction)
        alert.addAction(denyAction)
        
        return alert
    }
}