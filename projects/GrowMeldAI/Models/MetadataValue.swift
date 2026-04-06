enum MetadataValue: Codable, Equatable {
    case string(String)
    case integer(Int)
    case double(Double)
    case date(Date)
    
    // Custom Codable implementation for transparent encoding
}
