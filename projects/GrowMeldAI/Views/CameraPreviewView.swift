import SwiftUI

struct CameraPreviewView: View {
    var body: some View {
        ZStack {
            Color.black
                .accessibilityLabel("Kamera-Vorschau für Dokumenterfassung")
                .accessibilityHint("Tippe zum Fokussieren auf ein bestimmtes Objekt. Nutze zwei Finger zum Zoomen. Doppeltippe zum Erfassen.")
                .accessibilityElement(children: .combine)
        }
    }
}