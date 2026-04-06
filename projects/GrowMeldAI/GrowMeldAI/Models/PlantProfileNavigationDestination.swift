import Foundation

/// Navigation destinations for the Pflanzenprofil-Erstellung app.
/// Represents all possible routes within the plant profile application.
enum PlantProfileNavigationDestination: Hashable {
    /// The main home screen showing featured plants and quick actions.
    case home

    /// Detailed view of a specific plant.
    /// - Parameter id: The unique identifier of the plant.
    case plantDetail(id: UUID)

    /// Guide for identifying plants using camera or manual input.
    case identificationGuide

    /// Interactive flow for identifying unknown plants.
    case identificationFlow

    /// Screen for editing or creating a plant profile.
    case profileEditor

    /// User's learning journal showing progress and notes.
    case learningJournal

    /// Overview of the user's plant collection progress.
    case collectionProgress

    /// Application settings screen.
    case settings
}