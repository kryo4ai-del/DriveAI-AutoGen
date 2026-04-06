enum Location: String, Codable, Hashable {
    case motorway          // Autobahn
    case city              // Stadtgebiet
    case countryside       // Landstraße
    case parking           // Parkplatz
    case pedestrianZone    // Fußgängerzone
    case intersection      // Kreuzung
    case railroad          // Bahnübergang
    // Add: residential, school zone, highway, toll?
}