import SwiftUI

struct ConsentLogRow: View {
    let log: ConsentLog
    var body: some View {
        HStack {
            Text(log.consentType)
            Spacer()
            Text(log.granted ? "Granted" : "Denied")
        }
    }
}
