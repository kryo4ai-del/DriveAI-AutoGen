import Foundation

enum QuestionCategory: String, Codable, CaseIterable {
    case rightOfWay        = "Right of Way"
    case trafficSigns      = "Traffic Signs"
    case speed             = "Speed"
    case parking           = "Parking"
    case turning           = "Turning"
    case overtaking        = "Overtaking"
    case distance          = "Distance"
    case alcoholDrugs      = "Alcohol & Drugs"
    case safety            = "Safety"
    case vehicleTechnology = "Vehicle Technology"
    case environment       = "Environment"
    case general           = "General"
}
