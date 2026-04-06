extension PLZRegion {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)  // Hash only unique identifier
    }
    
    static func == (lhs: PLZRegion, rhs: PLZRegion) -> Bool {
        lhs.id == rhs.id  // Compare only ID
    }
}