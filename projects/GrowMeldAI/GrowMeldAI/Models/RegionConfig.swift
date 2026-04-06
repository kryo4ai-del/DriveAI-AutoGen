import SwiftUI

struct RegionConfig: Codable {
    let region: Region
    let primaryColor: Color
    let accentColor: Color
    
    static func config(for region: Region) -> RegionConfig {
        switch region {
        case .dach:
            return RegionConfig(
                region: .dach,
                primaryColor: Color(red: 0.0, green: 0.3, blue: 0.6),
                accentColor: Color(red: 1.0, green: 0.4, blue: 0.0)
            )
        case .au_victoria:
            return RegionConfig(
                region: .au_victoria,
                primaryColor: Color(red: 0.0, green: 0.4, blue: 0.8),
                accentColor: Color(red: 1.0, green: 0.8, blue: 0.0)
            )
        case .ca_ontario:
            return RegionConfig(
                region: .ca_ontario,
                primaryColor: Color(red: 0.2, green: 0.4, blue: 0.8),
                accentColor: Color(red: 1.0, green: 0.3, blue: 0.0)
            )
        }
    }
}