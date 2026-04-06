// Features/Camera/Views/CameraUnavailableCard.swift
import SwiftUI

/// Card shown when camera is unavailable
struct CameraUnavailableCard: View {
    var body: some View {
        CameraPermissionStateCard(
            icon: "camera.slash.fill",
            iconColor: .gray,
            title: "Kamera nicht verfügbar",
            description: "Ihr Gerät unterstützt keine Kamerafunktion.",
            actionTitle: nil,
            onAction: nil,
            secondaryText: "Bitte verwenden Sie ein Gerät mit Kamera, um fortzufahren."
        )
    }
}